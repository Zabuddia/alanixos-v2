{ pkgs-unstable, ... }:

{
  # Immich stores and organizes photos and videos. Its native NixOS module
  # also creates the local PostgreSQL, Redis, and machine-learning services.
  services.immich = {
    enable = true;
    # Stable still carries unsupported Immich 2.x; unstable supplies the
    # maintained release without weakening the global insecure-package policy.
    package = pkgs-unstable.immich;
    host = "0.0.0.0";
    port = 2283;
    openFirewall = false;
  };
}
