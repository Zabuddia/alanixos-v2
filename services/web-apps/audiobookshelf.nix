{
  config,
  pkgs-unstable,
  ...
}:

let
  domain = "audiobookshelf.fifefin.com";
  port = 13378;
in
{
  # Audiobookshelf serves audiobooks and podcasts with listening progress.
  services.audiobookshelf = {
    enable = true;
    package = pkgs-unstable.audiobookshelf;
    # Caddy is the only network-facing process; the application stays private.
    host = "127.0.0.1";
    inherit port;
    openFirewall = false;
  };

  # Media under Buddia's shared tree is group-readable by media services.
  users.users.${config.services.audiobookshelf.user}.extraGroups = [ "users" ];

  # Public routing stays with the application so removing this module removes
  # its proxy and DDNS entry as well.
  services.caddy.virtualHosts.${domain} = {
    logFormat = null; # Do not record request URLs that may contain credentials.
    extraConfig = "reverse_proxy 127.0.0.1:${toString port}";
  };
  services.ddclient.domains = [ domain ];
}
