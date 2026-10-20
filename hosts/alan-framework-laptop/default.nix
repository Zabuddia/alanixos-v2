{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/base.nix
  ];

  networking.hostName = "alan-framework-laptop";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Keep this at the release used for the machine's first NixOS installation.
  system.stateVersion = "25.11";
}
