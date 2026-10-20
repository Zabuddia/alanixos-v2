{
  pkgs,
  ...
}:

{
  imports = [
    ./apps/foot.nix
    ./apps/mako.nix
    ./apps/sway.nix
  ];

  home-manager.users.buddia = {
    home.packages = with pkgs; [
      grim
      pavucontrol
      slurp
      wl-clipboard
    ];
  };
}
