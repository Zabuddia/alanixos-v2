{ pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.gamemode.enable = true;
  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    gamescope
    heroic
    mangohud
    mesa-demos
    protonup-qt
    vulkan-tools
  ];
}
