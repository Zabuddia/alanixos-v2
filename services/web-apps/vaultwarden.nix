{ pkgs-unstable, ... }:

let
  domain = "vaultwarden.fifefin.com";
  port = 8222;
in
{
  # Vaultwarden is a lightweight Bitwarden-compatible password manager.
  services.vaultwarden = {
    enable = true;
    package = pkgs-unstable.vaultwarden;
    webVaultPackage = pkgs-unstable.vaultwarden.webvault;
    inherit domain;
    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = port;

      # Existing accounts remain application-managed, but arbitrary Internet
      # visitors may not create new vaults.
      SIGNUPS_ALLOWED = false;
    };
  };

  services.caddy.virtualHosts.${domain} = {
    logFormat = null; # Vault request paths should not be retained.
    extraConfig = "reverse_proxy 127.0.0.1:${toString port}";
  };
  services.ddclient.domains = [ domain ];
}
