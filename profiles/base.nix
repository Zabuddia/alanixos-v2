{
  hostname,
  lib,
  pkgs,
  ...
}:

{
  networking.hostName = hostname;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.download-buffer-size = 524288000;

  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = lib.mkDefault "America/Chicago";
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
    bat
    bind
    btop
    curl
    dosfstools
    duf
    eza
    fd
    file
    fzf
    git
    htop
    iotop
    jq
    lm_sensors
    lsof
    nano
    ncdu
    nmap
    openssl
    p7zip
    parted
    pciutils
    pv
    restic
    ripgrep
    rsync
    smartmontools
    sops
    strace
    tcpdump
    tmux
    traceroute
    tree
    unar
    unzip
    usbutils
    wget
    which
    xz
    zip
    zstd
  ];
}
