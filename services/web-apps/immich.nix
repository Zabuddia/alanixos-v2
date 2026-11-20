{ pkgs-unstable, ... }:

{
  # Immich stores and organizes photos and videos. Its native NixOS module
  # also creates the local PostgreSQL, Redis, and machine-learning services.
  services.immich = {
    enable = true;
    package = pkgs-unstable.immich;
    # Caddy is the only network-facing process; the application stays private.
    host = "127.0.0.1";
    port = 2283;
    openFirewall = false;
  };
}
