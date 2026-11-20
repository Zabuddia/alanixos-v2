{
  # This disk already contains the v1 Syncthing media tree. Its stable device
  # identifier belongs in this host-specific hardware module, not a shared profile.
  fileSystems."/srv/bulk" = {
    device = "/dev/disk/by-id/ata-ST20000NT001-3MB101_WYE0BDJX-part1";
    fsType = "xfs";
    options = [
      "nofail"
      "x-systemd.device-timeout=10s"
    ];
  };

  # Preserve the media path already stored in application databases and clients.
  fileSystems."/home/buddia/Syncthing/media" = {
    device = "/srv/bulk/syncthing/media";
    fsType = "none";
    options = [
      "bind"
      "nofail"
    ];
    depends = [ "/srv/bulk" ];
  };

  systemd.tmpfiles.rules = [
    "d /srv/bulk 0755 root root - -"
    "d /srv/bulk/syncthing/media 2775 buddia users - -"
    "d /home/buddia/Syncthing/media 2775 buddia users - -"
  ];

  # Do not let media services silently use an empty root-filesystem directory.
  systemd.services = {
    audiobookshelf.unitConfig.RequiresMountsFor = [ "/home/buddia/Syncthing/media" ];
    jellyfin.unitConfig.RequiresMountsFor = [ "/home/buddia/Syncthing/media" ];
    navidrome.unitConfig.RequiresMountsFor = [ "/home/buddia/Syncthing/media" ];
  };
}
