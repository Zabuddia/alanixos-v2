{
  config,
  lib,
  pkgs,
  ...
}:

let
  companionAddress = "127.0.0.1";
  companionPort = 8282;
  companionBasePath = "/companion";
  companionUrl = "http://${companionAddress}:${toString companionPort}${companionBasePath}";

  # Invidious Companion is not packaged by the pinned Nixpkgs revision. These
  # are official release binaries pinned by immutable GitHub asset ID and hash,
  # so the result is reproducible and cannot silently change between rebuilds.
  releaseAssets = {
    x86_64-linux = {
      id = 721765701;
      filename = "invidious_companion-x86_64-unknown-linux-gnu.tar.gz";
      hash = "sha256-mGUgCmmLW45Hl7BLuz8+RAHNHOyYFsJg/+eFeokD8KQ=";
    };
    aarch64-linux = {
      id = 721765838;
      filename = "invidious_companion-aarch64-unknown-linux-gnu.tar.gz";
      hash = "sha256-elO6XYniUhxGI8URMmd/W6exk+0xFO6YfsgDV6D1MeI=";
    };
  };
  releaseAsset =
    releaseAssets.${pkgs.stdenv.hostPlatform.system}
      or (throw "Invidious Companion has no pinned binary for ${pkgs.stdenv.hostPlatform.system}");

  companionPackage = pkgs.stdenvNoCC.mkDerivation {
    pname = "invidious-companion";
    # release-master is a rolling upstream release; this date identifies the
    # pinned assets rather than pretending that upstream publishes a version.
    version = "release-master-2026-11-07";

    src = pkgs.fetchurl {
      name = releaseAsset.filename;
      url = "https://api.github.com/repos/iv-org/invidious-companion/releases/assets/${toString releaseAsset.id}";
      inherit (releaseAsset) hash;

      # GitHub's release-asset API returns metadata unless this content type is requested.
      curlOptsList = [
        "--header"
        "Accept: application/octet-stream"
      ];
    };

    dontUnpack = true;
    installPhase = ''
      runHook preInstall

      mkdir -p "$out/bin"
      tar -xzf "$src"
      install -m0755 invidious_companion "$out/bin/invidious-companion"

      runHook postInstall
    '';

    meta = {
      description = "YouTube stream retrieval companion for Invidious";
      homepage = "https://github.com/iv-org/invidious-companion";
      license = lib.licenses.agpl3Plus;
      mainProgram = "invidious-companion";
      platforms = builtins.attrNames releaseAssets;
    };
  };
in
{
  # These values are decrypted only on alan-main-server. The template is
  # created at activation time, so neither key appears in the Nix store.
  sops.secrets.invidious-companion-key.mode = "0400";
  sops.secrets.invidious-hmac-key.mode = "0400";
  sops.templates.invidious-extra-settings = {
    content = builtins.toJSON {
      invidious_companion = [ { private_url = companionUrl; } ];
      invidious_companion_key = config.sops.placeholder.invidious-companion-key;

      # Keeping the HMAC key stable preserves existing login sessions.
      hmac_key = config.sops.placeholder.invidious-hmac-key;
    };
    owner = "invidious";
    group = "invidious";
    mode = "0400";
  };

  services.invidious.extraSettingsFile = config.sops.templates.invidious-extra-settings.path;

  # A fixed service account lets the activation-time settings file be readable
  # by Invidious without making it world-readable. Application login accounts
  # are still managed by Invidious itself, not as NixOS users.
  users.groups.invidious = { };
  users.users.invidious = {
    isSystemUser = true;
    group = "invidious";
    home = "/var/lib/invidious";
  };
  systemd.services.invidious = {
    after = [ "invidious-companion.service" ];
    requires = [ "invidious-companion.service" ];
    restartTriggers = [
      (builtins.hashString "sha256" config.sops.templates.invidious-extra-settings.content)
    ];
    serviceConfig = {
      # The upstream module normally creates a transient user. A fixed account
      # is required because the SOPS template has a fixed owner at activation.
      DynamicUser = lib.mkForce false;
      User = lib.mkForce "invidious";
      Group = lib.mkForce "invidious";
    };
  };
  systemd.tmpfiles.rules = [
    "d /var/lib/invidious 0750 invidious invidious - -"
  ];

  # Companion replaces inv-sig-helper and handles all YouTube stream retrieval.
  # It is loopback-only: clients use Invidious and never contact this port.
  systemd.services.invidious-companion = {
    description = "Invidious Companion";
    wantedBy = [ "multi-user.target" ];
    before = [ "invidious.service" ];
    wants = [ "network-online.target" ];
    after = [
      "network-online.target"
      "sops-nix.service"
    ];

    serviceConfig = {
      Type = "simple";
      User = "invidious";
      Group = "invidious";
      Restart = "always";
      RestartSec = "2s";

      # systemd exposes the secret through a private runtime credential rather
      # than an environment variable embedded in the generated unit or Nix store.
      LoadCredential = [
        "server_secret_key:${config.sops.secrets.invidious-companion-key.path}"
      ];

      # Companion caches YouTube's player scripts here; it is disposable cache,
      # but retaining it avoids downloading and evaluating them after every boot.
      StateDirectory = "invidious-companion";
      StateDirectoryMode = "0750";
      WorkingDirectory = "/var/lib/invidious-companion";

      # These standard systemd restrictions remove privileges the network
      # service does not need while still allowing outbound HTTP(S) requests.
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateTmp = true;
      ProtectControlGroups = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectSystem = "strict";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
    };

    path = [ pkgs.coreutils ];
    script = ''
      set -euo pipefail

      export SERVER_SECRET_KEY="$(tr -d '\r\n' < "$CREDENTIALS_DIRECTORY/server_secret_key")"
      export HOST=${lib.escapeShellArg companionAddress}
      export PORT=${lib.escapeShellArg (toString companionPort)}
      export SERVER_BASE_PATH=${lib.escapeShellArg companionBasePath}

      # Both processes share a private loopback connection, so Companion does
      # not need its optional public-request verification or URL encryption.
      export SERVER_VERIFY_REQUESTS=false
      export SERVER_ENCRYPT_QUERY_PARAMS=false

      # The compiled Deno program still needs writable locations for its
      # downloaded player-code cache. Its small key-value database is ephemeral.
      export CACHE_DIRECTORY=/var/lib/invidious-companion
      export DENO_DIR=/var/lib/invidious-companion/deno
      export DENO_KV_DEFAULT_PATH=:memory:

      exec ${lib.getExe companionPackage}
    '';
  };
}
