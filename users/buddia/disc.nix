{ pkgs, ... }:

{
  home-manager.users.buddia.home.packages = with pkgs; [
    handbrake # Transcodes video and compresses disc rips.
    makemkv # Extracts DVD and Blu-ray titles into MKV files.
  ];
}
