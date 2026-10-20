{
  config,
  hostname,
  lib,
  pkgs,
  ...
}:

let
  # The inventory is the single source of truth for names, addresses, and public keys.
  inventory = import ./inventory.nix;
  inherit (inventory) hub peers;
  thisPeer = peers.${hostname};
  hubPeer = peers.${hub};
  isHub = hostname == hub;
  otherPeers = lib.filterAttrs (name: _: name != hub) peers;
in
{
  # Decrypt the private key into a root-readable runtime file.
  sops.secrets.private-key.mode = "0400";

  # Make every peer reachable as either its hostname or `<hostname>.wg`.
  networking.hosts = lib.mapAttrs' (
    name: peer:
    lib.nameValuePair peer.address [
      name
      "${name}.wg"
    ]
  ) peers;

  # Clients connect only to the hub; the hub routes traffic between clients.
  networking.wireguard.interfaces.wg0 = {
    ips = [ "${thisPeer.address}/24" ];
    privateKeyFile = config.sops.secrets.private-key.path;
    peers =
      if isHub then
        lib.mapAttrsToList (_: peer: {
          inherit (peer) publicKey;
          allowedIPs = [ "${peer.address}/32" ];
        }) otherPeers
      else
        [
          {
            inherit (hubPeer) publicKey;
            endpoint = inventory.endpoint;
            # Route only the private WireGuard subnet through the tunnel.
            allowedIPs = [ "10.100.0.0/24" ];
            # Keeps NAT mappings alive for clients behind home routers.
            persistentKeepalive = 25;
          }
        ];
  }
  // lib.optionalAttrs isHub {
    listenPort = inventory.port;
  };

  networking.firewall = {
    # WireGuard peers may reach services otherwise protected by the host firewall.
    trustedInterfaces = [ "wg0" ];
    # Only the public hub needs to accept new WireGuard UDP sessions.
    allowedUDPPorts = lib.optionals isHub [ inventory.port ];
  };

  # The hub must forward packets from one WireGuard peer to another.
  boot.kernel.sysctl."net.ipv4.ip_forward" = lib.mkIf isHub 1;
  # Supplies `wg` for inspecting and troubleshooting the tunnel.
  environment.systemPackages = [ pkgs.wireguard-tools ];
}
