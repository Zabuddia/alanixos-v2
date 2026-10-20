{ pkgs, ... }:

{
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      foot
      fuzzel
      grim
      slurp
      swayidle
      swaylock
      waybar
      wl-clipboard
    ];
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd sway";
      user = "greeter";
    };
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.printing.enable = true;

  programs.dconf.enable = true;
  security.polkit.enable = true;
  security.rtkit.enable = true;

  fonts.packages = with pkgs; [
    dejavu_fonts
    liberation_ttf
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-color-emoji
  ];
}
