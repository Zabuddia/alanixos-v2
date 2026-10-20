{ config, ... }:

{
  sops.secrets.cloudflare-api-token.mode = "0400";

  services.ddclient = {
    enable = true;
    protocol = "cloudflare";
    username = "token";
    passwordFile = config.sops.secrets.cloudflare-api-token.path;
    zone = "fifefin.com";
    domains = [ "wireguard.fifefin.com" ];
    interval = "5min";
    quiet = true;
  };
}
