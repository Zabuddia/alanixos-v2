{ pkgs-unstable, ... }:

{
  # Immich stores and organizes photos and videos. Its native NixOS module
  # also creates the local PostgreSQL, Redis, and machine-learning services.
  services.immich = {
    enable = true;
    package = pkgs-unstable.immich;
    host = "0.0.0.0";
    port = 2283;
    openFirewall = false;
  };
}
