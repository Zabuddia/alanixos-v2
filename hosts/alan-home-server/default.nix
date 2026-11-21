{
  # MacBook Air repurposed as an always-on home-automation server.
  imports = [
    # Generated hardware, Broadcom Wi-Fi support, and private networking.
    ./hardware-configuration.nix
    ./hardware.nix
    ../../network/wireguard

    # This laptop is operated as an always-on server rather than a portable PC.
    ./always-on.nix
    ../../profiles/base.nix
    ../../profiles/desktop
    ../../profiles/desktop/bluetooth.nix

    # Home automation remains separate from the host's hardware and desktop.
    ../../services/home-assistant.nix

    ../../users/buddia.nix
    ../../users/buddia/desktop.nix
  ];

  swapDevices = [
    {
      device = "/swapfile";
      size = 8192;
    }
  ];
  # Preserve compatibility with the NixOS release first installed on this machine.
  system.stateVersion = "26.05";
}
