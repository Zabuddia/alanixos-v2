{ pkgs, ... }:

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

  # PipeWire handles audio; its PulseAudio compatibility supports older applications.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  # Grants real-time scheduling to audio processes to prevent dropouts.
  security.rtkit.enable = true;

  # Bluetooth is available immediately for controllers, headphones, and keyboards.
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    input.General.ClassicBondedOnly = false;
  };
  services.blueman.enable = true; # Graphical Bluetooth manager and tray applet.
  # Combines paired Nintendo Switch Joy-Cons into a single controller.
  services.joycond.enable = true;

  # dconf stores GTK application preferences.
  programs.dconf.enable = true;
  # Thunar is the graphical file manager; volman handles removable media.
  programs.thunar = {
    enable = true;
    plugins = [ pkgs.thunar-volman ];
  };
  services.gvfs.enable = true; # Trash, network shares, and removable-volume support.

  environment.systemPackages = with pkgs; [
    alsa-utils # Command-line audio controls and diagnostics.
    brightnessctl # Controls laptop and monitor backlight brightness.
  ];

  fonts.packages = with pkgs; [
    dejavu_fonts # General-purpose Latin font family.
    liberation_ttf # Metric-compatible replacements for common Microsoft fonts.
    nerd-fonts.symbols-only # Icons used by terminal and desktop status tools.
    noto-fonts # Broad Unicode language coverage.
    noto-fonts-color-emoji # Color emoji glyphs.
  ];
}
