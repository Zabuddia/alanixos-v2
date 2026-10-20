{
  imports = [
    ./hardware-configuration.nix
    ../../network/wireguard
    ../../profiles/base.nix
    ../../profiles/desktop
    ../../profiles/desktop/gaming.nix
    ../../profiles/desktop/printing.nix
    ../../services/flatpak.nix
    ../../services/sunshine.nix
    ../../services/tor.nix
    ../../users/buddia.nix
    ../../users/buddia/applications.nix
    ../../users/buddia/desktop.nix
    ../../users/buddia/gaming.nix
  ];

  time.timeZone = "America/Chicago";
  swapDevices = [
    {
      device = "/swapfile";
      size = 32768;
    }
  ];
  system.stateVersion = "25.11";
}
