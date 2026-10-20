{
  imports = [
    ./hardware-configuration.nix
    ../../network/wireguard
    ../../profiles/base.nix
    ../../profiles/desktop
    ../../profiles/desktop/printing.nix
    ../../users/buddia.nix
    ../../users/buddia/desktop.nix
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
