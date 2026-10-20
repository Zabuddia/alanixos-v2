{ pkgs-unstable, ... }:

{
  home-manager.users.buddia.programs.vscodium = {
    enable = true;
    package = pkgs-unstable.vscodium;
    profiles.default.extensions = with pkgs-unstable.vscode-extensions; [
      jnoortheen.nix-ide
      yzhang.markdown-all-in-one
    ];
  };
}
