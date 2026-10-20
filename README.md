# alanixos-v2

NixOS configurations for Alan's computers.

## Layout

- `hosts/<hostname>/`: hardware configuration and host-specific settings
- `profiles/`: reusable machine roles
- `network/`: shared network configuration and host inventory
- `users/`: user accounts and Home Manager configuration
- `services/`: reusable service configuration
- `secrets/`: SOPS-encrypted host secrets
- `flake.nix`: inputs and host definitions

## Commands

Run these commands from the repository root.

Format the Nix files:

```bash
nix fmt
```

Evaluate every configuration:

```bash
nix flake check --no-build
```

Build a host without activating it:

```bash
sudo nixos-rebuild build --flake .#<hostname>
```

Build and activate a host:

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

Update locked inputs:

```bash
nix flake update
```

## WireGuard

- Hub: `alan-main-server`
- Network: `10.100.0.0/24`
- Endpoint: `wireguard.fifefin.com:51820`
- Peer addresses and public keys: `network/wireguard/inventory.nix`
- Encrypted private keys: `secrets/wireguard/<hostname>.yaml`

The router at the hub location must forward UDP port `51820` to
`alan-main-server` at `192.168.10.225`.

## Adding a host

1. Create `hosts/<hostname>/default.nix`.
2. Add or generate `hosts/<hostname>/hardware-configuration.nix`.
3. Import the required profiles, users, and services from the host module.
4. Add the host to the host map in `flake.nix`.
5. Add its WireGuard address and public key to `network/wireguard/inventory.nix`.
6. Add its SOPS recipient to `.sops.yaml` and create
   `secrets/wireguard/<hostname>.yaml`.
7. Run `nix flake check --no-build`.
