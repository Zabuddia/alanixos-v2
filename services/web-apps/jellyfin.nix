{ config, ... }:

{
  # Jellyfin streams movies, shows, recordings, and other local video.
  services.jellyfin = {
    enable = true;
    openFirewall = false;
  };

  # Libraries keep their existing paths under /home/buddia/Syncthing/media.
  users.users.${config.services.jellyfin.user}.extraGroups = [ "users" ];
}
