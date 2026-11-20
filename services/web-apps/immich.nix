{ pkgs-unstable, ... }:

let
  domain = "immich.fifefin.com";
  port = 2283;
in
{
  # Immich stores and organizes photos and videos. Its native NixOS module
  # also creates the local PostgreSQL, Redis, and machine-learning services.
  services.immich = {
    enable = true;
    package = pkgs-unstable.immich;
    # Caddy is the only network-facing process; the application stays private.
    host = "127.0.0.1";
    inherit port;
    openFirewall = false;
  };

  services.caddy.virtualHosts.${domain} = {
    logFormat = null; # Do not record private asset paths or authentication URLs.
    extraConfig = "reverse_proxy 127.0.0.1:${toString port}";
  };
  services.ddclient.domains = [ domain ];
}
