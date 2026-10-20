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
    ../../services/flatpak.nix
    ../../services/sunshine.nix
    ../../services/tor.nix
    ../../users/buddia.nix
  ];

  networking.hostName = "alan-framework-laptop";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Keep this at the release used for the machine's first NixOS installation.
  system.stateVersion = "25.11";
}
