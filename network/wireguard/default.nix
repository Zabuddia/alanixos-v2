{
  config,
  hostname,
  lib,
  pkgs,
  ...
}:

let
  inventory = import ./inventory.nix;
  inherit (inventory) hub peers;
  thisPeer = peers.${hostname};
  hubPeer = peers.${hub};
  isHub = hostname == hub;
  otherPeers = lib.filterAttrs (name: _: name != hub) peers;
in
{
  sops = {
    defaultSopsFile = ../../secrets/wireguard/${hostname}.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
    secrets.private-key = {
      mode = "0400";
    };
  };

  networking.hosts = lib.mapAttrs' (
    name: peer:
    lib.nameValuePair peer.address [
      name
      "${name}.wg"
    ]
  ) peers;

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
            allowedIPs = [ "10.100.0.0/24" ];
            persistentKeepalive = 25;
          }
        ];
  }
  // lib.optionalAttrs isHub {
    listenPort = inventory.port;
  };

  networking.firewall = {
    trustedInterfaces = [ "wg0" ];
    allowedUDPPorts = lib.optionals isHub [ inventory.port ];
  };

  boot.kernel.sysctl."net.ipv4.ip_forward" = lib.mkIf isHub 1;
  environment.systemPackages = [ pkgs.wireguard-tools ];
}
