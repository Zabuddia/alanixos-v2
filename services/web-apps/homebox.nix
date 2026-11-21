{ pkgs-unstable, ... }:

let
  domain = "homebox.fifefin.com";
  port = 8092;
in
{
  # Homebox records household inventory, locations, warranties, and attachments.
  services.homebox = {
    enable = true;
    package = pkgs-unstable.homebox;
    settings = {
      HBOX_WEB_HOST = "127.0.0.1";
      HBOX_WEB_PORT = toString port;
      # Preserve existing accounts but prevent arbitrary Internet registration.
      HBOX_OPTIONS_ALLOW_REGISTRATION = "false";
    };
  };

  services.caddy.virtualHosts.${domain} = {
    logFormat = null; # Inventory item names and attachment paths are private.
    extraConfig = "reverse_proxy 127.0.0.1:${toString port}";
  };
  services.ddclient.domains = [ domain ];
}
