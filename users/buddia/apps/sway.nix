{
  lib,
  pkgs-unstable,
  ...
}:

{
  # Sway is the user's tiling Wayland desktop configuration.
  home-manager.users.buddia.wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4"; # Super/Windows key used for Sway shortcuts.
      terminal = lib.getExe pkgs-unstable.foot;
      # Wofi opens installed desktop applications by name.
      menu = "${lib.getExe pkgs-unstable.wofi} --show drun";
      # Provides the Bluetooth status icon and device menu.
      startup = [ { command = "blueman-applet"; } ];
    };
  };
}
