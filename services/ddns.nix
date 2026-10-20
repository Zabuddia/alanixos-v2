{ config, ... }:

{
  # ddclient reads the Cloudflare token from a root-only decrypted runtime file.
  sops.secrets.cloudflare-api-token.mode = "0400";

  # Keeps the WireGuard hostname correct when the home public IP changes.
  services.ddclient = {
    enable = true;
    protocol = "cloudflare";
    username = "token"; # Cloudflare's ddclient API-token authentication mode.
    passwordFile = config.sops.secrets.cloudflare-api-token.path;
    zone = "fifefin.com";
    domains = [ "wireguard.fifefin.com" ];
    interval = "5min"; # Frequent enough for residential address changes.
    quiet = true;
  };
}
