{ pkgs, pkgs-unstable, ... }:

{
  # Browsers with custom settings keep those settings in individual modules.
  imports = [
    ./apps/chromium.nix
    ./apps/librewolf.nix
  ];

  home-manager.users.buddia.home.packages = [
    pkgs.tor-browser # Browser configured to send traffic through Tor.
    pkgs-unstable.firefox # General-purpose web browser.
  ];
}
