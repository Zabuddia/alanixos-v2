{ pkgs, ... }:

{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.download-buffer-size = 524288000;

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  programs.nix-ld.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  environment.systemPackages = with pkgs; [
    age
    android-tools
    bind
    caddy
    curl
    dosfstools
    ffmpeg
    gparted
    git
    htop
    imagemagick
    jq
    lm_sensors
    lsof
    nodejs
    nano
    p7zip
    parted
    python3
    restic
    ripgrep
    sops
    tree
    unar
    unzip
    usbutils
    vlc
    w_scan2
    wget
    zip
  ];
}
