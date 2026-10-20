{ pkgs-unstable, ... }:

{
  # LibreWolf is the privacy-hardened Firefox-based browser.
  home-manager.users.buddia.programs.librewolf = {
    enable = true;
    package = pkgs-unstable.librewolf;
    settings."browser.toolbars.bookmarks.visibility" = "never";
    # Reject cookies by default while allowing sites that require persistent login.
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
