# alanixos-v2

NixOS configurations for Alan's computers.

## Design

- Host files compose reusable profiles, user capabilities, network modules, and services.
- Shared facts have one source of truth instead of being copied between hosts.
- Services are private by default and are exposed only when their module says so.
- Physical LAN addresses are not stored in the repository. Hosts use DHCP through NetworkManager.
- WireGuard addresses identify machines on the private overlay and do not depend on their current LAN.
- System and user configuration is expressed through Nix; persistent runtime state is documented separately.
- Secrets are encrypted per host with SOPS and are decrypted only on the target machine.
- Hardware configuration stays with the physical computer; roles and reusable behavior stay in modules.

## Hosts

| Host | Purpose | Configured functionality |
| --- | --- | --- |
| `alan-main-server` | Private-network hub and primary server | WireGuard hub, Cloudflare DDNS, administration desktop |
| `alan-ai-server` | AI, GPU, media, and gaming system | Local model APIs, OpenClaw, speech services, desktop, gaming, Tor, Sunshine |
| `alan-framework-laptop` | Primary portable computer | Desktop, development, documents, graphics, gaming, media, disc tools, printing, Tor, Sunshine, laptop power management |
| `alan-home-server` | Home-automation server | Home Assistant, local-device discovery, administration desktop, laptop hardware management |
| `alan-bitcoin-node` | Bitcoin infrastructure | Bitcoin Core, Fulcrum, Mempool, Tor and onion services |
| `alan-backup-server` | Backup and disc-ingest server | Administration desktop and disc tools |
| `alan-tv-pc` | Alan's living-room computer | Media, disc tools, gaming and Sunshine |
| `randy-main-server` | Randy's primary server | Administration desktop |
| `randy-tv-pc` | Randy's living-room computer | Media, gaming and Sunshine |

The host name is the final network identity. The repository does not create legacy or temporary aliases.

## Composition

`flake.nix` creates every `nixosConfigurations.<hostname>` output through the same builder. A host normally imports modules in this order:

1. Its generated hardware configuration and any hardware-specific fixes.
2. Private networking from `network/`.
3. Reusable operating-system capabilities from `profiles/`.
4. Only the services that should run on that host.
5. The user account and required application capabilities from `users/`.

Host files should contain facts unique to that machine, such as its role, time zone, swap size, hardware groups, and selected capabilities. Shared implementation belongs in a profile, network module, user module, or service module.

## Layout

- `hosts/<hostname>/`: host composition, generated hardware configuration, and hardware-specific behavior
- `profiles/`: reusable operating-system capabilities such as desktop, laptop, gaming, and printing support
- `network/wireguard/`: WireGuard implementation and the authoritative peer inventory
- `users/`: declarative accounts and groups
- `users/<name>/`: application capability groups selected by hosts
- `users/<name>/apps/`: applications that have their own configuration
- `services/`: reusable system services selected explicitly by hosts
- `secrets/hosts/`: SOPS-encrypted secrets readable only by the administrator and intended host
- `.sops.yaml`: secret-file recipient rules
- `flake.nix`: inputs, the shared host builder, and the host list
- `flake.lock`: exact dependency revisions used for reproducible evaluation

## Profiles and applications

`profiles/base.nix` supplies common Nix, boot, locale, NetworkManager, firewall, SSH, and command-line administration settings.

`profiles/desktop/` supplies the minimal graphical system: Sway, greetd, PipeWire, Bluetooth, Thunar, removable-media support, fonts, and graphical privilege prompts. Gaming, controller support, and printing remain separate capabilities so a host receives them only when needed.

Home Manager owns Buddia's shell, Git configuration, SSH agent, user applications, and Sway configuration. Applications with meaningful settings have individual files under `users/buddia/apps/`; simple package collections are grouped by purpose under `users/buddia/`.

Users are immutable with `users.mutableUsers = false`. Buddia's password hash is decrypted before account creation, so account changes must be made through this repository.

## Services

### Main-server applications

`services/web-apps/` contains one native NixOS module per application. The directory's `default.nix` imports the complete set only on `alan-main-server`; there is no cluster controller, failover layer, container wrapper, or custom user-reconciliation service.

The applications currently listen on all addresses but do not open their ports in the global firewall. Trusted WireGuard peers can reach them at:

| Application | Purpose | WireGuard address |
| --- | --- | --- |
| Audiobookshelf | Audiobooks and podcasts | `http://alan-main-server.wg:13378` |
| Immich | Photos and videos | `http://alan-main-server.wg:2283` |
| Invidious | Alternative YouTube interface | `http://alan-main-server.wg:3001` |
| Jellyfin | Movies, television, recordings, and video | `http://alan-main-server.wg:8096` |
| Navidrome | Music streaming and Subsonic API | `http://alan-main-server.wg:4533` |
| Open WebUI | Browser interface for the local AI models | `http://alan-main-server.wg:18080` |
| Radicale | CalDAV calendars and CardDAV contacts | `http://alan-main-server.wg:5232` |
| SearXNG | Private metasearch | `http://alan-main-server.wg:8888` |
| Vaultwarden | Bitwarden-compatible password manager | `http://alan-main-server.wg:8222` |

Open WebUI uses LiteLLM on `alan-ai-server` and SearXNG on the same main server. Immich uses its NixOS-managed local PostgreSQL, Redis, and machine-learning services. Invidious uses its NixOS-managed local PostgreSQL database.

Current Invidious releases require Invidious Companion for YouTube stream retrieval; it replaces the older `inv-sig-helper`. The pinned Nixpkgs revision does not package Companion, so `invidious-companion.nix` packages the official prebuilt release using an immutable GitHub asset ID and SHA-256 hash, then runs it as a hardened systemd service. It listens only on `127.0.0.1:8282`, is not exposed to clients, and stores its disposable player-script cache in `/var/lib/invidious-companion`. Its shared key and Invidious's session HMAC key are decrypted by SOPS at activation and never enter the Nix store. Updating Companion requires replacing the release asset IDs and hashes for both supported architectures in that file.

The operating system and NixOS service modules remain on stable `26.05`, while all nine application packages come explicitly from `nixpkgs-unstable`. This provides current upstream application releases without moving the entire operating system to an unstable NixOS branch.

Open WebUI has one isolated package override that splits a malformed Nixpkgs wrapper argument into its three intended arguments. It changes no application source or runtime behavior and can be removed when the unstable package expression contains the correction.

Application accounts remain in the applications' own databases. Existing accounts are retained when their v1 state directories are present; a fresh instance uses its normal first-run setup. Open WebUI makes its first account the administrator and leaves later accounts pending. Invidious and Vaultwarden registration are enabled while the services are WireGuard-only so initial accounts can be created; disable registration before adding public exposure. Vaultwarden's browser vault requires trusted HTTPS for normal Web Crypto support, so its public exposure must provide TLS.

Radicale is the exception because it has no account-management interface. Its `buddia` account and password are declared through SOPS, and its rights restrict users to their own collections. SearXNG has no user accounts.

`hosts/alan-main-server/storage.nix` mounts the existing bulk disk and presents its v1 media tree at `/home/buddia/Syncthing/media`. This preserves the library paths already stored by Audiobookshelf, Jellyfin, and Navidrome. The service databases and other mutable application state remain under their native `/var/lib` locations.

### AI stack

`services/ai/` contains the complete AI stack and is imported only by `alan-ai-server`:

- `models.nix` runs the local models and the LiteLLM compatibility endpoint.
- `openclaw.nix` owns the Jarvis gateway, declarative configuration, workspace files, credentials, and command-execution policy.
- `speech.nix` provides Wyoming speech-to-text and text-to-speech services for Home Assistant.

OpenClaw is independently pinned to the known-working `2026.6.33` Nixpkgs revision. The current unstable package fails during its upstream plugin-asset build; the separate input keeps that workaround isolated from NixOS and every other unstable application.

The enabled model services are:

| Service | Purpose | Port |
| --- | --- | --- |
| Qwen 3.8 27B | Vision and image understanding | `8086` |
| Ornith 1.5 35B A3B | Jarvis reasoning and tool use | `8088` |
| Qwen3 Embedding 4B | OpenClaw semantic memory | `8082` |
| Whisper Small | OpenAI-compatible audio transcription | `8085` |
| LiteLLM | One OpenAI-compatible endpoint for the local models | `4000` |
| Wyoming Piper | Home Assistant text-to-speech | `10200` |
| Wyoming Faster Whisper | Home Assistant speech-to-text | `10300` |

The model services use Vulkan acceleration and run as the unprivileged `llm` system user. Model downloads and caches remain under `/var/lib/llm` so the existing v1 downloads can be reused; the Wyoming services keep their downloaded models in their systemd state directories. Services bind to the machine so WireGuard peers can use them, but the normal firewall does not expose them on physical network interfaces. Because `wg0` is intentionally trusted, every WireGuard peer can reach these ports.

OpenClaw runs as a lingering user service owned by `buddia`. Its gateway listens on port `18789`, requires the SOPS-managed gateway token, and can be opened over WireGuard at `http://alan-ai-server.wg:18789`. Telegram is restricted to Alan's configured Telegram account. Its Home Assistant MCP connection targets `alan-home-server` over WireGuard.

OpenClaw also owns a dedicated headless Chromium profile for browser automation. It does not reuse Alan's interactive browser profile, cookies, or open tabs. Idle automated tabs are cleaned up so a long-running gateway does not accumulate browser processes indefinitely. Its web-search tool uses the SearXNG instance on `alan-main-server` instead of a commercial search API.

Jarvis intentionally has unrestricted gateway-host command execution. Its requested policy and local approval file both use full execution without prompts. Because it runs as `buddia` and Buddia has passwordless sudo, Jarvis can effectively administer the entire AI server. This is an explicit trust decision, not an accidental default.

The v1 custom model dashboard was not carried forward. Standard service inspection keeps the implementation smaller:

```bash
systemctl status ai-ornith ai-qwen-vision ai-embeddings ai-whisper ai-litellm
journalctl -fu ai-ornith
systemctl --user status openclaw-gateway
journalctl --user -fu openclaw-gateway
openclaw models list
openclaw channels status --probe
openclaw browser --browser-profile openclaw status
```

The first service start downloads the configured models and can take substantial time and storage. Rebuilds reuse the persistent downloads.

### Home Assistant

`services/home-assistant.nix` restores the home-automation core on `alan-home-server`. Nix owns the stable YAML configuration and package dependencies, while Home Assistant keeps device registries, history, dashboards, credentials, and UI-managed integrations under `/var/lib/hass`. Reusing that v1 state directory preserves existing devices and the long-lived token used by OpenClaw.

The module includes the dependencies for the standard dashboard, Bluetooth, ESPHome, local calendars and task lists, MCP, MQTT clients, Piper, system monitoring, Wake-on-LAN, Wyoming, and ZHA. Including an integration makes it available; integrations still requiring credentials or device selection are configured through Home Assistant's UI and retained in its runtime state.

Home Assistant listens on port `8123` but does not open that port on physical network interfaces. It is available through trusted WireGuard at:

```text
http://alan-home-server.wg:8123
```

Avahi opens mDNS discovery so the server can find DHCP-assigned smart-home devices on its current LAN. The Home Assistant MCP endpoint lets Jarvis use the token already stored in the AI server's SOPS document. Wyoming connects Home Assistant to the speech services on `alan-ai-server`.

The old anonymous MQTT broker was deliberately not restored. The MQTT integration is present, but a broker should be added later with declarative users and credentials instead of accepting anonymous read/write access to every topic.

### Bitcoin node

`services/bitcoin-node.nix` scopes nix-bitcoin to `alan-bitcoin-node` and enables:

- Bitcoin Core with `txindex` and Tor-enforced networking
- Fulcrum as the private Electrum server
- Mempool as the block explorer
- Bitcoin Core, Fulcrum, Mempool, and SSH onion services
- automatic generation of service credentials outside the Nix store
- `buddia` as the nix-bitcoin operator

The blockchain, indexes, generated credentials, and Tor identities are persistent state. Preserve the relevant `/var/lib` data, `/etc/nix-bitcoin-secrets`, and `/var/lib/tor` when reinstalling or moving the node.

### Sunshine

`services/sunshine.nix` installs the Sunshine game-streaming service on selected hosts. It is not started automatically. Its Web UI password comes from the host's SOPS document and is reapplied before every start. WireGuard is trusted by the firewall, so Sunshine does not open its ports on every physical network interface.

### Tor

`services/tor.nix` provides a local SOCKS5 proxy for applications on selected hosts. The Bitcoin node has its own Tor configuration because it also publishes onion services.

### WireGuard DDNS

`services/ddns.nix` runs only on `alan-main-server`. It updates the public WireGuard endpoint from the values in `network/wireguard/inventory.nix`; the endpoint is not duplicated in the DDNS module.

## WireGuard

`network/wireguard/inventory.nix` is the single source of truth for:

- the hub host
- the virtual WireGuard subnet
- the public endpoint name and port
- every peer's stable WireGuard address and public key

The current topology is hub-and-spoke:

- `alan-main-server` accepts connections from every peer.
- Other hosts connect only to `alan-main-server`.
- The hub forwards traffic between WireGuard peers.
- Each host is reachable as `<hostname>` and `<hostname>.wg` while the configuration is active.
- Only the WireGuard subnet is routed through the tunnel; ordinary internet traffic uses the host's current network.

The addresses assigned in the inventory are virtual overlay addresses, not addresses from a home, office, or public LAN. A computer can move between physical networks without changing its WireGuard identity.

The network hosting `alan-main-server` must forward the UDP port declared as `port` in the WireGuard inventory to:

```text
<alan-main-server-LAN-IP>
```

That address belongs in the router's DHCP reservation and port-forward configuration, not in this repository. If the hub moves to another network, reserve its new LAN address and update that router's forwarding rule. Cloudflare DDNS updates the inventory's `endpointHost` when the public address changes.

## Secrets and authentication

Each host reads `secrets/hosts/<hostname>.yaml`. The encrypted files currently contain:

- the host's WireGuard private key
- Buddia's password hash
- the Cloudflare DDNS token on `alan-main-server`
- the Sunshine Web UI password on hosts that run Sunshine
- the OpenClaw gateway token on `alan-ai-server`
- the OpenClaw Telegram bot token on `alan-ai-server`
- the Home Assistant token used by OpenClaw on `alan-ai-server`

The matching age identity must exist at `/var/lib/sops-nix/key.txt` before a host can activate a configuration that uses secrets. This identity is bootstrap material and must be transferred securely; it is never committed to Git.

Edit a host's encrypted document with:

```bash
sops secrets/hosts/<hostname>.yaml
```

When adding a secret, declare its owner and permissions in the module that consumes it. Do not place plaintext credentials, private keys, passwords, tokens, or generated runtime secrets in Nix files.

## Declarative boundary

Nix declares the desired operating-system and application configuration, but some state cannot be regenerated safely on every rebuild:

- `/var/lib/sops-nix/key.txt` is the bootstrap identity that lets a machine decrypt its host secrets.
- Sunshine retains authorized-client pairing state after its SOPS-managed Web UI password is applied.
- nix-bitcoin generates service credentials and Tor identities on the node because committing their values would expose them.
- Local model downloads and caches under `/var/lib/llm` are large reproducible runtime data.
- OpenClaw keeps conversations, memory, pairing information, and other mutable state under `/home/buddia/.openclaw`; its configuration and workspace instructions remain declarative.
- Home Assistant keeps device registries, history, dashboards, and UI-managed integrations under `/var/lib/hass`; Nix owns its stable base configuration and installed components.
- Main-server applications keep accounts, libraries, databases, thumbnails, indexes, and settings in their native `/var/lib` state directories. Radicale authentication and stable service settings remain declarative.
- Applications and services keep user data, databases, caches, indexes, and downloaded content outside the Nix store.

Treat this as persistent data, not configuration. Back it up or migrate it when it is irreplaceable. Do not solve runtime state by committing generated files or secrets to Git.

## Commands

Run commands from the repository root.

Format every Nix file:

```bash
nix fmt
```

Evaluate every host and flake output without building them:

```bash
nix flake check --no-build
```

Build one host without activating it:

```bash
sudo nixos-rebuild build --flake .#<hostname>
```

Build and activate the configuration for the current host:

```bash
sudo nixos-rebuild switch --flake .#$(hostname)
```

Activate a named host configuration:

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

Update all locked inputs, then evaluate every host before committing:

```bash
nix flake update
nix flake check --no-build
```

## Adding a host

1. Choose its final descriptive hostname.
2. Create `hosts/<hostname>/default.nix` and its hardware configuration.
3. Import only the profiles, services, user, and application capabilities it needs.
4. Add the host to the map in `flake.nix`.
5. Add its stable WireGuard address and public key to `network/wireguard/inventory.nix`.
6. Add its age recipient to `.sops.yaml`.
7. Create `secrets/hosts/<hostname>.yaml` with its WireGuard private key and password hash.
8. Run `nix fmt` and `nix flake check --no-build`.
9. Build the host configuration before activating it.

## Adding functionality

- Put hardware-specific behavior under the corresponding host directory.
- Put a reusable operating-system capability under `profiles/`.
- Put a system daemon or network-facing workload under `services/`.
- Put a user application with configuration under `users/<name>/apps/`.
- Put a simple group of related user packages in a purpose-named file under `users/<name>/`.
- Keep secrets beside neither hosts nor services in plaintext; declare them in the consuming module and store their values in the host's encrypted document.
- Add comments for behavior, security boundaries, and non-obvious settings. Do not comment syntax that already explains itself.
