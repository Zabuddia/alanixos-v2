{ pkgs, ... }:

{
  # Node.js runs JavaScript tooling and applications outside the browser.
  # Project dependencies belong in project lockfiles; shared CLI tools belong in Nix.
  home-manager.users.buddia.home.packages = [ pkgs.nodejs ];
}
