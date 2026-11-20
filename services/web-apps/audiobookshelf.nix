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
    host = "0.0.0.0";
    port = 13378;
    openFirewall = false;
  };

  # Media under Buddia's shared tree is group-readable by media services.
  users.users.${config.services.audiobookshelf.user}.extraGroups = [ "users" ];
}
