{ pkgs, pkgs-unstable, ... }:

{
  home-manager.users.buddia.home.packages = [
    pkgs.hyprpicker # Picks a color from any point on a Wayland screen.
    pkgs.imagemagick # Command-line image conversion and manipulation.
    pkgs-unstable.gimp # Full graphical image editor.
  ];
}
