{ pkgs, ... }:

{
  # Node.js and VSCodium have settings kept in individual modules.
  imports = [
    ./apps/nodejs.nix
    ./apps/vscodium.nix
  ];

  home-manager.users.buddia.home.packages = with pkgs; [
    android-tools # ADB and Fastboot tools for Android devices.
    android-studio # Android application IDE and SDK manager.
    python3 # Python interpreter for scripts and development tools.
  ];
}
