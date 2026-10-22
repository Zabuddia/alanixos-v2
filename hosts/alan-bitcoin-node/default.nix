{
  # Dedicated machine reserved for the Bitcoin node workload.
  imports = [
    # Machine hardware and private network membership.
    ./hardware-configuration.nix
    ../../network/wireguard

    # Minimal graphical system and user session for administration.
    ../../profiles/base.nix
    ../../profiles/desktop
    ../../services/bitcoin-node.nix
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
  system.stateVersion = "25.11";
}
