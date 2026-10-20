{ pkgs, pkgs-unstable, ... }:

{
  home-manager.users.buddia.home.packages = [
    pkgs.kodi-wayland
    pkgs.makemkv
    (pkgs.retroarch.withCores (
      cores: with cores; [
        gambatte
        genesis-plus-gx
        mgba
        mupen64plus
        nestopia
        snes9x
      ]
    ))
    pkgs-unstable.azahar
    pkgs-unstable.dolphin-emu
    pkgs-unstable.eden
    pkgs-unstable.melonds
    pkgs-unstable.ryubing
  ];
}
