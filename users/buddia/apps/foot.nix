{ pkgs-unstable, ... }:

{
  home-manager.users.buddia.programs.foot = {
    enable = true;
    package = pkgs-unstable.foot;
  };
}
