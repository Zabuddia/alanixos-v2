{
  # MacBook Air repurposed as an always-on home-automation server.
  imports = [
    # Generated hardware, Broadcom Wi-Fi support, and private networking.
    ./hardware-configuration.nix
    ./hardware.nix
    ../../network/wireguard

    # The laptop profile manages the battery and older mobile hardware.
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
  # Preserve compatibility with the NixOS release first installed on this machine.
  system.stateVersion = "26.05";
}
