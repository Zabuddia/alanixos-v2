{ ... }:

{
  imports = [
    ./buddia/apps/bash.nix
    ./buddia/apps/git.nix
    ./buddia/apps/ssh.nix
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
      };

      programs.home-manager.enable = true;
    };
  };
}
