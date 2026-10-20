{ lib, pkgs, ... }:

let
  swapFile = "/swapfile";
in
{
  # Hibernate needs swap large enough to store the laptop's active memory.
  swapDevices = [
    {
      device = swapFile;
      size = 20480;
    }
  ];

  # systemd in the initrd can resume the saved image before mounting the root filesystem.
  boot.initrd.systemd.enable = true;

  # Closing the lid suspends first, then hibernates after the delay below.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandleLidSwitchDocked = "ignore";
  };

  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "30min";
    HibernateOnACPower = "no";
  };

  # A swap file can move on disk, so calculate its physical resume offset at each boot.
  systemd.services.hibernate-resume-swapfile = {
    description = "Refresh hibernate resume location for ${swapFile}";
    after = [ "swap.target" ];
    before = [ "systemd-logind.service" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [
      e2fsprogs
      gawk
      util-linux
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -euo pipefail

      swap_file=${lib.escapeShellArg swapFile}
      swapon --noheadings --show=NAME | grep -Fxq "$swap_file"
      backing_device="$(findmnt --noheadings --output SOURCE --target "$swap_file")"
      major_minor="$(lsblk --noheadings --output MAJ:MIN "$backing_device" | head -n1 | tr -d '[:space:]')"
      resume_offset="$(filefrag -v "$swap_file" | awk '$1 == "0:" { gsub(/\.\./, "", $4); print $4; exit }')"

      test -n "$major_minor"
      test -n "$resume_offset"
      printf '%s' "$resume_offset" > /sys/power/resume_offset
      printf '%s' "$major_minor" > /sys/power/resume
    '';
  };
}
