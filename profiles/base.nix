{
  hostname,
  lib,
  pkgs,
  ...
}:

{
  # The flake output name is also the machine's network hostname.
  networking.hostName = hostname;

  # Required for commands such as `nix build` and flake-based rebuilds.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # Avoids disk-buffer warnings while downloading large store paths.
  nix.settings.download-buffer-size = 524288000;

  # Several explicitly selected applications have unfree licenses.
  nixpkgs.config.allowUnfree = true;

  # Every current machine boots in UEFI mode with systemd-boot.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hosts in other locations override this default in their host module.
  time.timeZone = lib.mkDefault "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  # Runs dynamically linked third-party Linux binaries that expect FHS library paths.
  programs.nix-ld.enable = true;

  # Key-only SSH provides remote administration without password logins.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  environment.systemPackages = with pkgs; [
    age # File encryption used by SOPS recipients.
    bat # `cat`-style file viewer with syntax highlighting.
    bind # DNS tools such as `dig` and `nslookup`.
    btop # Interactive CPU, memory, disk, and network monitor.
    curl # Transfers data to and from URLs and APIs.
    dosfstools # Creates and repairs FAT filesystems used by EFI partitions.
    duf # Readable overview of mounted filesystem usage.
    eza # Modern directory listing tool compatible with common `ls` workflows.
    fd # Fast, user-friendly alternative to `find`.
    file # Identifies a file's actual format from its contents.
    fzf # Interactive fuzzy finder for shell pipelines.
    git # Version control used by this repository.
    htop # Interactive process viewer.
    iotop # Shows which processes are performing disk I/O.
    jq # Queries and transforms JSON.
    lm_sensors # Reads supported temperatures, fan speeds, and voltages.
    lsof # Lists processes using files, devices, and network sockets.
    nano # Simple terminal text editor.
    ncdu # Interactive disk-usage browser.
    nmap # Discovers hosts and inspects network ports.
    openssl # Inspects certificates and performs common cryptographic operations.
    p7zip # Reads and writes 7z archives.
    parted # Creates and inspects disk partition tables.
    pciutils # Supplies `lspci` for identifying PCI hardware.
    pv # Displays progress while data moves through a pipe.
    restic # Encrypted, deduplicated backups.
    ripgrep # Fast recursive text search through files.
    rsync # Efficient local and remote file synchronization.
    smartmontools # Reads SMART health information from storage devices.
    sops # Edits and decrypts repository secrets.
    strace # Traces system calls for debugging programs.
    tcpdump # Captures and inspects network packets.
    tmux # Keeps persistent terminal sessions and split panes.
    traceroute # Shows the network path to a remote host.
    tree # Prints directory structures as a tree.
    unar # Extracts many archive formats with automatic filename handling.
    unzip # Extracts ZIP archives.
    usbutils # Supplies `lsusb` for identifying USB hardware.
    wget # Downloads files non-interactively.
    which # Shows which executable a shell command resolves to.
    xz # Compresses and extracts XZ/LZMA files.
    zip # Creates ZIP archives.
    zstd # Fast modern compression used by many backup and package formats.
  ];
}
