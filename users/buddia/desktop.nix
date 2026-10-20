{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  home-manager.users.buddia = {
    home.packages = with pkgs; [
      grim
      pavucontrol
      slurp
      wl-clipboard
    ];

    programs.foot = {
      enable = true;
      package = pkgs-unstable.foot;
    };

    services.mako.enable = true;

    wayland.windowManager.sway = {
      enable = true;
      config = {
        modifier = "Mod4";
        terminal = lib.getExe pkgs-unstable.foot;
        menu = "${lib.getExe pkgs-unstable.wofi} --show drun";
        startup = [ { command = "blueman-applet"; } ];
      };
    };
  };
}
