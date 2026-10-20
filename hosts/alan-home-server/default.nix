{
  imports = [
    ./hardware-configuration.nix
    ./hardware.nix
    ../../network/wireguard
    ../../profiles/base.nix
    ../../profiles/desktop
    ../../profiles/laptop.nix
    ../../users/buddia.nix
    ../../users/buddia/desktop.nix
  ];

  time.timeZone = "America/Chicago";
  swapDevices = [
    {
      device = "/swapfile";
      size = 8192;
    }
  ];
  system.stateVersion = "26.05";
}
