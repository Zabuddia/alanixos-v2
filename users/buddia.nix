{ ... }:

{
  # Shell, Git, and the SSH agent are available to Buddia on every machine.
  imports = [
    ./buddia/apps/bash.nix
    ./buddia/apps/git.nix
    ./buddia/apps/ssh.nix
  ];

  users.users.buddia = {
    isNormalUser = true;
    description = "Alan Fife";
    extraGroups = [
      "input" # Physical and virtual input devices.
      "kvm" # Hardware-accelerated virtual machines.
      "networkmanager" # NetworkManager control without root.
      "video" # Graphics, brightness, and video devices.
      "wheel" # Administrative access through sudo.
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExSf9y7yGFQySwkx42MXCgZ6EkgP2PebAJb4++5X0SB fife.alan@protonmail.com"
    ];
  };

  # These are personal machines; wheel members can administer them non-interactively.
  security.sudo.wheelNeedsPassword = false;

  # Home Manager owns Buddia's user packages and dotfiles as part of each NixOS rebuild.
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.buddia = {
      home = {
        username = "buddia";
        homeDirectory = "/home/buddia";
        stateVersion = "25.11";
        # Makes user-installed scripts and npm command wrappers directly executable.
        sessionPath = [ "/home/buddia/.local/bin" ];
      };

      programs.home-manager.enable = true;
    };
  };
}
