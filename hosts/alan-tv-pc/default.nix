{
  # Living-room PC for television, local media, disc playback, and games.
  imports = [
    # Machine hardware and private network membership.
    ./hardware-configuration.nix
    ../../network/wireguard

    # Graphical and system-wide gaming support.
    ../../profiles/base.nix
    ../../profiles/desktop
    ../../profiles/desktop/gaming.nix
    # Sunshine lets another Moonlight client stream this desktop when requested.
    ../../services/sunshine.nix

    # User account plus desktop, disc, gaming, and media applications.
    ../../users/buddia.nix
    ../../users/buddia/desktop.nix
    ../../users/buddia/disc.nix
    ../../users/buddia/gaming.nix
    ../../users/buddia/media.nix
  ];

  time.timeZone = "America/Chicago";
  # Access to the USB HDMI-CEC adapter exposed as a serial device.
  users.users.buddia.extraGroups = [ "dialout" ];
  # Preserve compatibility with the NixOS release first installed on this machine.
  system.stateVersion = "26.05";
}
