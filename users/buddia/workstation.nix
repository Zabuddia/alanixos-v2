{ pkgs, pkgs-unstable, ... }:

{
  # Applications with settings are split out so their configuration is easy to find.
  imports = [
    ./apps/chromium.nix
    ./apps/librewolf.nix
    ./apps/nodejs.nix
    ./apps/vscodium.nix
  ];

  home-manager.users.buddia = {
    home.packages =
      (with pkgs; [
        android-tools # ADB and Fastboot tools for Android devices.
        android-studio # Android application IDE and SDK manager.
        featherpad # Lightweight graphical text editor.
        gparted # Graphical disk partition editor.
        hyprpicker # Picks a color from any point on a Wayland screen.
        imagemagick # Command-line image conversion and manipulation.
        libreoffice # Office documents, spreadsheets, and presentations.
        marktext # Graphical Markdown editor.
        python3 # Python interpreter for scripts and development tools.
        remmina # Graphical RDP, VNC, and SSH remote-desktop client.
        tor-browser # Browser configured to send traffic through Tor.
        usbimager # Writes operating-system images to USB drives and SD cards.
        wdisplays # Graphical Wayland monitor arrangement tool.
        xournalpp # Handwritten notes and PDF annotation.
        zoom-us # Zoom video meetings.
      ])
      ++ (with pkgs-unstable; [
        firefox # General-purpose web browser.
        gimp # Full graphical image editor.
        sparrow # Desktop Bitcoin wallet and transaction-management tool.
      ]);
  };
}
