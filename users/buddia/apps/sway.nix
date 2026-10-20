{
  lib,
  pkgs-unstable,
  ...
}:

{
  home-manager.users.buddia.wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4";
      terminal = lib.getExe pkgs-unstable.foot;
      menu = "${lib.getExe pkgs-unstable.wofi} --show drun";
      startup = [ { command = "blueman-applet"; } ];
    };
  };
}
