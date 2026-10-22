{
  inputs,
  lib,
  ...
}:

let
  # Prefer nix-bitcoin's privacy-preserving defaults without preventing a
  # deliberate host-specific override later.
  defaultTrue = lib.mkDefault true;
in
{
  # Scope nix-bitcoin's service options to the Bitcoin host rather than making
  # every machine configure its secrets system.
  imports = [ inputs.nix-bitcoin.nixosModules.default ];

  nix-bitcoin = {
    # Generate service credentials on the node and keep them out of the Nix
    # store and Git repository.
    generateSecrets = true;

    # Buddia can use bitcoin-cli, nodeinfo, logs, and the enabled service tools
    # without maintaining a separate interactive operator account.
    operator = {
      enable = true;
      name = "buddia";
    };

    security.dbusHideProcessInformation = true;
    nodeinfo.enable = true;

    # Publish private endpoints for each user-facing service. The generated Tor
    # identity keys must be retained when migrating to preserve their addresses.
    onionServices = {
      bitcoind.enable = defaultTrue;
      fulcrum.enable = defaultTrue;
      mempool-frontend = {
        enable = true;
        externalPort = 80;
      };
    };

    # Lets Buddia read the SSH onion address alongside the Bitcoin addresses.
    onionAddresses.access.buddia = [ "sshd" ];
  };

  services = {
    tor = {
      enable = true;
      client.enable = true;

      # SSH remains reachable through Tor even when the normal network path is
      # unavailable. Key-only authentication is enforced by the base profile.
      relay.onionServices.sshd = {
        version = 3;
        map = [
          {
            port = 22;
            target = {
              addr = "127.0.0.1";
              port = 22;
            };
          }
        ];
      };
    };

    bitcoind = {
      enable = true;
      listen = true;
      dbCache = 1000;
      # Required by applications that need historical transaction lookup.
      txindex = true;
      tor = {
        proxy = defaultTrue;
        enforce = defaultTrue;
      };
    };

    # Fulcrum builds an Electrum index so wallets can query this Bitcoin node
    # instead of trusting a public Electrum server.
    fulcrum = {
      enable = true;
      tor.enforce = defaultTrue;
    };

    # Mempool provides a local block explorer backed by Bitcoin Core and
    # Fulcrum. Port 4080 is reachable locally and through trusted WireGuard;
    # the onion service above provides the private remote endpoint.
    mempool = {
      enable = true;
      electrumServer = "fulcrum";
      tor = {
        proxy = defaultTrue;
        enforce = defaultTrue;
      };
      frontend = {
        address = "0.0.0.0";
        port = 4080;
      };
    };
  };
}
