{ config, ... }:

let
  # The WireGuard inventory owns the public endpoint so DDNS cannot drift from it.
  inventory = import ../network/wireguard/inventory.nix;
in
{
  # ddclient reads the Cloudflare token from a root-only decrypted runtime file.
  sops.secrets.cloudflare-api-token.mode = "0400";

  # Keeps the WireGuard hostname correct when the home public IP changes.
  services.ddclient = {
    enable = true;
    protocol = "cloudflare";
    username = "token"; # Cloudflare's ddclient API-token authentication mode.
    passwordFile = config.sops.secrets.cloudflare-api-token.path;
    zone = inventory.dnsZone;
    domains = [ inventory.endpointHost ];
    interval = "5min"; # Frequent enough for residential address changes.
    quiet = true;
  };
}
