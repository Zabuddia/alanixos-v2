{
  imports = [
    ./hardware-configuration.nix
    ../../network/wireguard
    ../../profiles/base.nix
    ../../profiles/desktop
    ../../profiles/desktop/gaming.nix
    ../../services/sunshine.nix
    ../../users/buddia.nix
    ../../users/buddia/desktop.nix
    ../../users/buddia/gaming.nix
    ../../users/buddia/media.nix
  ];

  time.timeZone = "America/New_York";
  system.stateVersion = "26.05";
}
