{
  # Central always-on server and WireGuard hub for Alan's machines.
  imports = [
    # Machine hardware and private network membership.
    ./hardware-configuration.nix
    ./storage.nix
    ../../network/wireguard

    # Basic graphical system for local or remote administration.
    ../../profiles/base.nix
    ../../profiles/desktop

    # Keeps the public WireGuard endpoint synchronized with the home IP.
    ../../services/ddns.nix

    # Application services and their public reverse-proxy routes.
    ../../services/web-apps

    # User account and minimal desktop session.
    ../../users/buddia.nix
    ../../users/buddia/desktop.nix
  ];

  swapDevices = [
    {
      device = "/swapfile";
      size = 8192;
    }
  ];
  # Preserve compatibility with the NixOS release first installed on this machine.
  system.stateVersion = "25.11";
}
