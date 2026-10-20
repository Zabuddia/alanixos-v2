{ pkgs-unstable, ... }:

{
  imports = [ ./apps/retroarch.nix ];

  home-manager.users.buddia.home.packages = [
    pkgs-unstable.azahar
    pkgs-unstable.dolphin-emu
    pkgs-unstable.eden
    pkgs-unstable.melonds
    pkgs-unstable.moonlight-qt
    pkgs-unstable.ryubing
  ];
}
