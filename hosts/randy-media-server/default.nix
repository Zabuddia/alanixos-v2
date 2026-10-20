{
  imports = [
    ./hardware-configuration.nix
    ../../network/wireguard
    ../../profiles/base.nix
    ../../profiles/desktop
    ../../users/buddia.nix
    ../../users/buddia/desktop.nix
  ];

  time.timeZone = "America/Denver";
  swapDevices = [
    {
      device = "/swapfile";
      size = 8192;
    }
  ];
  system.stateVersion = "25.11";
}
