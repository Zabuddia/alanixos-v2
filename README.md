# alanixos-v2

A deliberately small NixOS configuration rebuilt from first principles.

The existing `alanixos` repository remains the production source of truth while
this repository grows. Configuration is moved here intentionally, one machine
or service at a time. It is not ready to switch onto yet.

## Current scope

- One host: `alan-framework-laptop`
- One shared profile: `profiles/base.nix`
- No custom option framework
- No cluster or automatic failover
- No secrets or state copied from the existing repository

## Commands

Evaluate everything without building a system closure:

```bash
nix flake check --no-build
```

Format the Nix files:

```bash
nix fmt
```

Inspect the proposed laptop configuration without activating it:

```bash
sudo nixos-rebuild dry-build --flake .#alan-framework-laptop
```

Do not run `nixos-rebuild switch` from this repository until the laptop profile
contains the desktop, user access, networking, and other features you need.

## Design rules

1. Prefer normal NixOS options over a custom namespace.
2. Keep host files as short lists of imports plus hardware-specific settings.
3. Copy a small configuration before abstracting it prematurely.
4. Every stateful service must document its data, backup, and restore process.
5. Reliability comes from understandable recovery before automatic failover.
