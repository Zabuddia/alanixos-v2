{
  # Bash is the interactive shell; aliases cover common repository operations.
  home-manager.users.buddia.programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ll = "ls -alh";
      rebuild = "sudo nixos-rebuild switch --flake ~/.nixos-v2#$(hostname)";
    };
  };
}
