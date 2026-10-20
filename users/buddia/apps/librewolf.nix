{ pkgs-unstable, ... }:

{
  home-manager.users.buddia.programs.librewolf = {
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
}
