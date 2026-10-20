{
  imports = [
    ./hardware-configuration.nix
    ./framework.nix
    ./power.nix
    ../../profiles/base.nix
    ../../profiles/desktop
    ../../profiles/desktop/gaming.nix
    ../../profiles/desktop/printing.nix
    ../../profiles/laptop.nix
    ../../network/wireguard
    ../../services/flatpak.nix
    ../../services/sunshine.nix
    ../../services/tor.nix
    ../../users/buddia.nix
    ../../users/buddia/applications.nix
    ../../users/buddia/desktop.nix
    ../../users/buddia/gaming.nix
  ];

  # Keep this at the release used for the machine's first NixOS installation.
  system.stateVersion = "25.11";
}
