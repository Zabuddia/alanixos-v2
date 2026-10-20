{ pkgs, pkgs-unstable, ... }:

{
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
        nodejs
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

    programs.chromium = {
      enable = true;
      package = pkgs-unstable.ungoogled-chromium;
      commandLineArgs = [
        "--ozone-platform=wayland"
        "--disable-features=VaapiVideoDecodeLinuxGL"
        "--homepage=about:blank"
        "--no-default-browser-check"
      ];
    };

    programs.librewolf = {
      enable = true;
      package = pkgs-unstable.librewolf;
      settings."browser.toolbars.bookmarks.visibility" = "never";
      policies.Cookies = {
        Behavior = "reject";
        Allow = [
          "https://chatgpt.com"
          "https://chess.com"
          "https://github.com"
          "https://lichess.org"
        ];
      };
    };

    programs.vscodium = {
      enable = true;
      package = pkgs-unstable.vscodium;
      profiles.default.extensions = with pkgs-unstable.vscode-extensions; [
        jnoortheen.nix-ide
        yzhang.markdown-all-in-one
      ];
    };

    services.nextcloud-client = {
      enable = true;
      startInBackground = true;
    };
  };
}
