{ pkgs-unstable, ... }:

{
  # VSCodium is VS Code built without Microsoft's branding and telemetry.
  home-manager.users.buddia.programs.vscodium = {
    enable = true;
    package = pkgs-unstable.vscodium;
    profiles.default.extensions = with pkgs-unstable.vscode-extensions; [
      jnoortheen.nix-ide # Nix syntax and language-server integration.
      yzhang.markdown-all-in-one # Markdown editing shortcuts and previews.
    ];
  };
}
