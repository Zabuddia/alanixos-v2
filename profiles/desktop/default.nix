{ pkgs, ... }:

{
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
      user = "greeter";
    };
  };

  services.gnome.gnome-keyring.enable = true;
  services.gnome.gcr-ssh-agent.enable = false;
  security.polkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    input.General.ClassicBondedOnly = false;
  };
  services.blueman.enable = true;
  services.joycond.enable = true;

  programs.dconf.enable = true;
  programs.thunar = {
    enable = true;
    plugins = [ pkgs.thunar-volman ];
  };
  services.gvfs.enable = true;

  environment.systemPackages = with pkgs; [
    alsa-utils
    brightnessctl
  ];

  fonts.packages = with pkgs; [
    dejavu_fonts
    liberation_ttf
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-color-emoji
  ];
}
