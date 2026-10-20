{ pkgs, pkgs-unstable, ... }:

{
  home-manager.users.buddia.home.packages = [
    pkgs.ffmpeg
    pkgs.kid3
    pkgs.kodi-wayland
    pkgs.lrcget
    pkgs.vlc
    pkgs.w_scan2
    pkgs-unstable.yt-dlp
  ];
}
