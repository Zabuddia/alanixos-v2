{
  imports = [
    ./hardware-configuration.nix
    ../../network/wireguard
    ../../profiles/base.nix
    ../../profiles/desktop
    ../../users/buddia.nix
    ../../users/buddia/desktop.nix
    ../../users/buddia/disc.nix
  ];

  time.timeZone = "America/Chicago";
  users.users.buddia.extraGroups = [ "cdrom" ];
  swapDevices = [
    {
      device = "/swapfile";
      size = 8192;
    }
  ];
  system.stateVersion = "25.11";
}
