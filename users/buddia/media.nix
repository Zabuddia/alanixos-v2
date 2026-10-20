{ pkgs, pkgs-unstable, ... }:

{
  home-manager.users.buddia.home.packages = [
    pkgs.ffmpeg # Converts, records, and inspects audio and video.
    pkgs.kid3 # Edits music file tags and album metadata.
    pkgs.kodi-wayland # Television-oriented media center running natively on Wayland.
    pkgs.lrcget # Finds and embeds synchronized song lyrics.
    pkgs.vlc # General-purpose audio and video player.
    pkgs.w_scan2 # Scans broadcast television channels for tuner software.
    pkgs-unstable.yt-dlp # Downloads video or audio from supported websites.
  ];
}
