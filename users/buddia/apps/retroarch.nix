{ pkgs, ... }:

{
  # RetroArch provides one frontend for selected classic-console emulator cores.
  home-manager.users.buddia.home.packages = [
    (pkgs.retroarch.withCores (
      cores: with cores; [
        gambatte # Game Boy and Game Boy Color.
        genesis-plus-gx # Genesis, Mega Drive, Master System, and Game Gear.
        mgba # Game Boy Advance, plus Game Boy and Game Boy Color.
        mupen64plus # Nintendo 64.
        nestopia # Nintendo Entertainment System.
        snes9x # Super Nintendo.
      ]
    ))
  ];
}
