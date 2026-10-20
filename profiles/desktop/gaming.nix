{ pkgs, ... }:

{
  # Games and Proton need both native 64-bit and legacy 32-bit graphics drivers.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.gamemode.enable = true; # Temporarily applies performance tuning for games.
  # The NixOS module supplies Steam plus its required libraries and hardware integration.
  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    gamescope # Nested gaming compositor for resolution, scaling, and fullscreen control.
    heroic # Launcher for Epic, GOG, and Amazon game libraries.
    mangohud # Optional in-game FPS and hardware-performance overlay.
    mesa-demos # OpenGL test and diagnostic programs such as `glxinfo`.
    protonup-qt # Installs community Proton compatibility-tool versions.
    vulkan-tools # Vulkan capability and diagnostic utilities.
  ];
}
