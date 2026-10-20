{ pkgs, ... }:

{
  users.users.buddia = {
    isNormalUser = true;
    description = "Alan Fife";
    extraGroups = [
      "input"
      "kvm"
      "networkmanager"
      "video"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExSf9y7yGFQySwkx42MXCgZ6EkgP2PebAJb4++5X0SB fife.alan@protonmail.com"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.buddia = {
      home = {
        username = "buddia";
        homeDirectory = "/home/buddia";
        stateVersion = "25.11";
        packages = with pkgs; [
          firefox
          libreoffice
          remmina
          tmux
          vlc
          xournalpp
        ];
      };

      programs = {
        bash = {
          enable = true;
          enableCompletion = true;
        };

        git = {
          enable = true;
          settings = {
            user.name = "Alan Fife";
            user.email = "fife.alan@protonmail.com";
            init.defaultBranch = "main";
          };
        };

        home-manager.enable = true;
      };
    };
  };
}
