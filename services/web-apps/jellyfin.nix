{
  config,
  pkgs-unstable,
  ...
}:

{
  # Jellyfin streams movies, shows, recordings, and other local video.
  services.jellyfin = {
    enable = true;
    package = pkgs-unstable.jellyfin;
    openFirewall = false;
  };

  # Libraries keep their existing paths under /home/buddia/Syncthing/media.
  users.users.${config.services.jellyfin.user}.extraGroups = [ "users" ];
}
