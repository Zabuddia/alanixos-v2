{ pkgs, ... }:

{
  imports = [
    ./buddia/applications.nix
    ./buddia/desktop.nix
    ./buddia/gaming.nix
  ];

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
        sessionPath = [ "/home/buddia/.local/bin" ];
        sessionVariables = {
          NPM_CONFIG_PREFIX = "/home/buddia/.local";
          NODE_PATH = "/home/buddia/.local/lib/node_modules";
        };
      };

      programs = {
        bash = {
          enable = true;
          enableCompletion = true;
          shellAliases = {
            ll = "ls -alh";
            rebuild = "sudo nixos-rebuild switch --flake ~/.nixos-v2#$(hostname)";
          };
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

  programs.ssh.startAgent = true;
}
