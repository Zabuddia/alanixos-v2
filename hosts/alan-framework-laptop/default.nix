{
  # Primary portable workstation with the complete desktop application set.
  imports = [
    # Generated hardware plus Framework-specific audio and power behavior.
    ./hardware-configuration.nix
    ./framework.nix
    ./power.nix

    # Private networking and operating-system capabilities.
    ../../network/wireguard
    ../../profiles/base.nix
    ../../profiles/desktop
    ../../profiles/desktop/gaming.nix
    ../../profiles/desktop/printing.nix
    ../../profiles/laptop.nix

    # Optional network-facing services.
    ../../services/sunshine.nix
    ../../services/tor.nix

    # User account and application capabilities.
    ../../users/buddia.nix
    ../../users/buddia/desktop.nix
    ../../users/buddia/disc.nix
    ../../users/buddia/gaming.nix
    ../../users/buddia/media.nix
    ../../users/buddia/workstation.nix
  ];

  # Keep this at the release used for the machine's first NixOS installation.
  system.stateVersion = "25.11";
}
