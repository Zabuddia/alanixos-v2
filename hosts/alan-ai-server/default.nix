{
  imports = [
    ./hardware-configuration.nix
    ../../network/wireguard
    ../../profiles/base.nix
    ../../profiles/desktop
    ../../profiles/desktop/gaming.nix
    ../../services/sunshine.nix
    ../../services/tor.nix
    ../../users/buddia.nix
    ../../users/buddia/desktop.nix
    ../../users/buddia/gaming.nix
    ../../users/buddia/media.nix
    ../../users/buddia/workstation.nix
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
