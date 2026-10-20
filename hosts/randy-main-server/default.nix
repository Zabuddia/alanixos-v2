{
  # Randy's always-on server for future storage and household services.
  imports = [
    # Machine hardware and private network membership.
    ./hardware-configuration.nix
    ../../network/wireguard

    # Basic graphical system and user session for administration.
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
  # Preserve compatibility with the NixOS release first installed on this machine.
  system.stateVersion = "25.11";
}
