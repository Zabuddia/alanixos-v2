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
    ../../users/buddia/disc.nix
    ../../users/buddia/gaming.nix
    ../../users/buddia/media.nix
  ];

  time.timeZone = "America/Chicago";
  users.users.buddia.extraGroups = [ "dialout" ];
  system.stateVersion = "26.05";
}
