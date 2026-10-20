{
  # GPU-capable workstation for AI workloads, remote streaming, media, and games.
  imports = [
    # Machine hardware and private network membership.
    ./hardware-configuration.nix
    ../../network/wireguard

    # Operating-system capabilities.
    ../../profiles/base.nix
    ../../profiles/desktop
    ../../profiles/desktop/gaming.nix

    # Optional network-facing services.
    ../../services/sunshine.nix
    ../../services/tor.nix

    # User account and application capabilities.
    ../../users/buddia.nix
    ../../users/buddia/apps/chromium.nix
    ../../users/buddia/apps/nodejs.nix
    ../../users/buddia/apps/vscodium.nix
    ../../users/buddia/desktop.nix
    ../../users/buddia/gaming.nix
    ../../users/buddia/media.nix
  ];

  time.timeZone = "America/Chicago";
  # Extra swap provides breathing room when large local models exhaust RAM.
  swapDevices = [
    {
      device = "/swapfile";
      size = 32768;
    }
  ];
  # Preserve compatibility with the NixOS release first installed on this machine.
  system.stateVersion = "25.11";
}
