{ pkgs, ... }:

{
  home-manager.users.buddia.home.packages = with pkgs; [
    featherpad # Lightweight graphical text editor.
    libreoffice # Office documents, spreadsheets, and presentations.
    marktext # Graphical Markdown editor.
    xournalpp # Handwritten notes and PDF annotation.
  ];
}
