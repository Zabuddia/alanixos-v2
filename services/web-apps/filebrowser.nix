{
  lib,
  pkgs-unstable,
  ...
}:

let
  domain = "filebrowser.fifefin.com";
  port = 8088;
  root = "/srv/bulk/syncthing/filebrowser";
in
{
  # File Browser provides a web interface for Alan's shared files. Its database
  # retains accounts and settings, while the browsed files remain on bulk storage.
  services.filebrowser = {
    enable = true;
    package = pkgs-unstable.filebrowser;
    openFirewall = false;
    settings = {
      address = "127.0.0.1";
      inherit port root;
      database = "/var/lib/filebrowser/filebrowser.db";
    };
  };

  # Shared files use the same group-writable ownership model as the media tree.
  users.users.filebrowser.extraGroups = [ "users" ];
  systemd.services.filebrowser.serviceConfig.UMask = lib.mkForce "0002";
  systemd.tmpfiles.settings.filebrowser.${root}.d = {
    user = lib.mkForce "buddia";
    group = lib.mkForce "users";
    mode = lib.mkForce "2775";
  };

  services.caddy.virtualHosts.${domain} = {
    logFormat = null; # File names and paths should not be retained in access logs.
    extraConfig = "reverse_proxy 127.0.0.1:${toString port}";
  };
  services.ddclient.domains = [ domain ];
}
