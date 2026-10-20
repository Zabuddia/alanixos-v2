{
  imports = [
    ./hardware-configuration.nix
    ./framework.nix
    ./power.nix
    ../../network/wireguard
    ../../profiles/base.nix
    ../../profiles/desktop
    ../../profiles/desktop/gaming.nix
    ../../profiles/desktop/printing.nix
    ../../profiles/laptop.nix
    ../../services/sunshine.nix
    ../../services/tor.nix
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
