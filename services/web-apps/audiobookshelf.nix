{
  config,
  pkgs-unstable,
  ...
}:

{
  # Audiobookshelf serves audiobooks and podcasts with listening progress.
  services.audiobookshelf = {
    enable = true;
    package = pkgs-unstable.audiobookshelf;
    # Caddy is the only network-facing process; the application stays private.
    host = "127.0.0.1";
    port = 13378;
    openFirewall = false;
  };

  # Media under Buddia's shared tree is group-readable by media services.
  users.users.${config.services.audiobookshelf.user}.extraGroups = [ "users" ];
}
