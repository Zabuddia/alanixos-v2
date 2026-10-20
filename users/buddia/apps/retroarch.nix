{ pkgs, ... }:

{
  home-manager.users.buddia.home.packages = [
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
  ];
}
