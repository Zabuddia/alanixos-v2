{
  # Backup and disc-ingest server built from the Dell OptiPlex.
  imports = [
    # Machine hardware and private network membership.
    ./hardware-configuration.nix
    ../../network/wireguard

    # Basic graphical system for local administration and disc work.
    ../../profiles/base.nix
    ../../profiles/desktop

    # User account, desktop, and disc tools.
    ../../users/buddia.nix
    ../../users/buddia/desktop.nix
    ../../users/buddia/disc.nix
  ];

  time.timeZone = "America/Chicago";
  # Grants direct access to the optical drive for MakeMKV and HandBrake.
  users.users.buddia.extraGroups = [ "cdrom" ];
  swapDevices = [
    {
      device = "/swapfile";
      size = 8192;
    }
  ];
  # Preserve compatibility with the NixOS release first installed on this machine.
  system.stateVersion = "25.11";
}
