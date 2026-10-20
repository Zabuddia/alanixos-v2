{
  pkgs,
  ...
}:

{
  # Configured desktop applications live in individual modules.
  imports = [
    ./apps/foot.nix
    ./apps/mako.nix
    ./apps/sway.nix
  ];

  home-manager.users.buddia = {
    home.packages = with pkgs; [
      grim # Captures Wayland screenshots.
      pavucontrol # Graphical PipeWire/PulseAudio volume and device controls.
      slurp # Selects a screen region, commonly for use with grim.
      wl-clipboard # Wayland `wl-copy` and `wl-paste` commands.
    ];
  };
}
