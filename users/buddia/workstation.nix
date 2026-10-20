{ pkgs, pkgs-unstable, ... }:

{
  imports = [
    ./apps/chromium.nix
    ./apps/librewolf.nix
    ./apps/nodejs.nix
    ./apps/vscodium.nix
  ];

  home-manager.users.buddia = {
    home.packages =
      (with pkgs; [
        android-tools
        android-studio
        featherpad
        gparted
        hyprpicker
        imagemagick
        libreoffice
        marktext
        python3
        remmina
        tor-browser
        usbimager
        wdisplays
        xournalpp
        zoom-us
      ])
      ++ (with pkgs-unstable; [
        firefox
        gimp
        sparrow
      ]);
  };
}
