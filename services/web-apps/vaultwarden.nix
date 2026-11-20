{ pkgs-unstable, ... }:

{
  # Vaultwarden is a lightweight Bitwarden-compatible password manager.
  services.vaultwarden = {
    enable = true;
    package = pkgs-unstable.vaultwarden;
    webVaultPackage = pkgs-unstable.vaultwarden.webvault;
    config = {
      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = 8222;

      # Accounts remain application-managed. This is safe only while the
      # service is private to trusted WireGuard peers and must be disabled
      # before any public reverse proxy is enabled.
      SIGNUPS_ALLOWED = true;
    };
  };
}
