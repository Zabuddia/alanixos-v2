{ pkgs-unstable, ... }:

{
  # RetroArch has configured cores, so it is kept in its own application module.
  imports = [ ./apps/retroarch.nix ];

  home-manager.users.buddia.home.packages = [
    pkgs-unstable.azahar # Nintendo 3DS emulator.
    pkgs-unstable.dolphin-emu # GameCube and Wii emulator.
    pkgs-unstable.eden # Nintendo Switch emulator.
    pkgs-unstable.melonds # Nintendo DS and DSi emulator.
    pkgs-unstable.moonlight-qt # Client for streaming games from Sunshine hosts.
    pkgs-unstable.ryubing # Alternative Nintendo Switch emulator.
  ];
}
