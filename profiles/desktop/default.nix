{ lib, pkgs, ... }:

{
  # Sway is the Wayland compositor and window manager for every graphical host.
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # greetd presents a small text login screen and starts Sway after login.
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
      user = "greeter";
    };
  };

  # Stores application credentials and unlocks them with the login session.
  services.gnome.gnome-keyring.enable = true;
  # The regular OpenSSH agent is used instead of GNOME's competing agent.
  services.gnome.gcr-ssh-agent.enable = false;
  # Allows desktop applications to request privileged actions through prompts.
  security.polkit.enable = true;

  # NixOS enables audio and speech services for every graphical session by
  # default. Priority 900 disables that default while still letting audio.nix's
  # ordinary settings opt selected hosts back in.
  services.pipewire.enable = lib.mkOverride 900 false;
  services.speechd.enable = lib.mkOverride 900 false;

  # dconf stores GTK application preferences.
  programs.dconf.enable = true;
  # Thunar is the graphical file manager; volman handles removable media.
  programs.thunar = {
    enable = true;
    plugins = [ pkgs.thunar-volman ];
  };
  services.gvfs.enable = true; # Trash, network shares, and removable-volume support.

  fonts.packages = with pkgs; [
    dejavu_fonts # General-purpose Latin font family.
    liberation_ttf # Metric-compatible replacements for common Microsoft fonts.
    nerd-fonts.symbols-only # Icons used by terminal and desktop status tools.
    noto-fonts # Broad Unicode language coverage.
    noto-fonts-color-emoji # Color emoji glyphs.
  ];
}
