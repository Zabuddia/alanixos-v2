{ pkgs, ... }:

{
  home-manager.users.buddia.home.packages = with pkgs; [
    handbrake
    makemkv
  ];
}
