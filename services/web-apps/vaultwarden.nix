{ pkgs-unstable, ... }:

{
  # Vaultwarden is a lightweight Bitwarden-compatible password manager.
  services.vaultwarden = {
    enable = true;
    package = pkgs-unstable.vaultwarden;
    webVaultPackage = pkgs-unstable.vaultwarden.webvault;
    domain = "vaultwarden.fifefin.com";
    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;

      # Existing accounts remain application-managed, but arbitrary Internet
      # visitors may not create new vaults.
      SIGNUPS_ALLOWED = false;
    };
  };
}
