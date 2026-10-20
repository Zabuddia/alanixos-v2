{ pkgs-unstable, ... }:

{
  # Foot is a fast, Wayland-native terminal used by Sway.
  home-manager.users.buddia.programs.foot = {
    enable = true;
    package = pkgs-unstable.foot;
  };
}
