# alanixos-v2

NixOS configurations for Alan's computers.

## Layout

- `hosts/<hostname>/`: hardware configuration and host-specific settings
- `profiles/`: reusable machine roles
- `users/`: user accounts and Home Manager configuration
- `services/`: reusable service configuration
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

## Adding a host

1. Create `hosts/<hostname>/default.nix`.
2. Add or generate `hosts/<hostname>/hardware-configuration.nix`.
3. Import the required profiles, users, and services from the host module.
4. Add the host to `nixosConfigurations` in `flake.nix`.
5. Run `nix flake check --no-build`.
