{
  config,
  lib,
  openclawPackage,
  pkgs,
  ...
}:

let
  # The WireGuard inventory remains the source of the gateway's private address.
  inventory = import ../../network/wireguard/inventory.nix;
  wireguardAddress = lib.removeSuffix "/32" inventory.peers.alan-ai-server.address;
  stateDir = "/home/buddia/.openclaw";
  # Reuse Jarvis's v1 workspace so existing memory remains available.
  workspaceDir = "${stateDir}/workspaces/jarvis";
  json = pkgs.formats.json { };

  # OpenClaw has both a requested exec policy and a host approval policy. Both
  # are intentionally unrestricted because Alan selected full Jarvis control.
  approvals = json.generate "openclaw-exec-approvals.json" {
    version = 1;
    defaults = {
      security = "full";
      ask = "off";
      askFallback = "full";
      autoAllowSkills = false;
    };
    agents.jarvis = {
      security = "full";
      ask = "off";
      askFallback = "full";
      autoAllowSkills = false;
    };
  };

  openclawConfig = json.generate "openclaw.json" {
    gateway = {
      mode = "local";
      port = 18789;
      # Binding to the LAN address also includes WireGuard; the NixOS firewall
      # keeps the port closed on untrusted physical network interfaces.
      bind = "lan";
      auth.mode = "token";
      tailscale.mode = "off";
      controlUi = {
        dangerouslyDisableDeviceAuth = true;
        allowedOrigins = [
          "http://127.0.0.1:18789"
          "http://alan-ai-server:18789"
          "http://alan-ai-server.wg:18789"
          "http://${wireguardAddress}:18789"
        ];
      };
    };

    # OpenClaw uses LiteLLM as its single local model provider. No real API key
    # is sent because the proxy is reachable only on this machine and WireGuard.
    models = {
      mode = "merge";
      providers.local = {
        baseUrl = "http://127.0.0.1:4000/v1";
        api = "openai-completions";
        apiKey = "local-litellm";
        authHeader = false;
        timeoutSeconds = 600;
        models = [
          {
            id = "ornith-1.5-35b-a3b";
            name = "Ornith 1.5 35B A3B";
            reasoning = true;
            input = [ "text" ];
            cost = {
              input = 0;
              output = 0;
              cacheRead = 0;
              cacheWrite = 0;
            };
            contextWindow = 65536;
            maxTokens = 32768;
          }
          {
            id = "qwen3.8-27b";
            name = "Qwen 3.8 27B";
            reasoning = false;
            input = [
              "text"
              "image"
            ];
            cost = {
              input = 0;
              output = 0;
              cacheRead = 0;
              cacheWrite = 0;
            };
            contextWindow = 131072;
            maxTokens = 4096;
          }
        ];
      };
    };

    # Jarvis keeps its v1 identity, sessions, and durable workspace paths.
    agents = {
      defaults = {
        workspace = workspaceDir;
        skipBootstrap = true;
        model = {
          primary = "local/ornith-1.5-35b-a3b";
          fallbacks = [ ];
        };
        imageModel = {
          primary = "local/qwen3.8-27b";
          fallbacks = [ ];
        };
        memorySearch = {
          provider = "openai-compatible";
          model = "qwen3-embedding-4b";
          fallback = "none";
          remote = {
            baseUrl = "http://127.0.0.1:8082/v1";
            apiKey = "local";
          };
        };
      };
      list = [
        {
          id = "jarvis";
          default = true;
          name = "Jarvis";
          workspace = workspaceDir;
          agentDir = "${stateDir}/agents/jarvis/agent";
          model = {
            primary = "local/ornith-1.5-35b-a3b";
            fallbacks = [ ];
          };
        }
      ];
    };

    # The minimal profile starts with a small tool set; alsoAllow lists every
    # additional capability Jarvis is expected to use.
    tools = {
      profile = "minimal";
      alsoAllow = [
        "cron"
        "bundle-mcp"
        "browser"
        "edit"
        "exec"
        "image"
        "memory_get"
        "memory_search"
        "process"
        "read"
        "web_fetch"
        "web_search"
        "write"
      ];
      exec = {
        host = "gateway";
        mode = "full";
        strictInlineEval = false;
      };
      fs.workspaceOnly = false;
      loopDetection.enabled = true;
    };

    # A dedicated headless Chromium profile keeps automated browsing separate
    # from Alan's interactive browser data and cookies.
    browser = {
      enabled = true;
      executablePath = lib.getExe pkgs.ungoogled-chromium;
      headless = true;
      noSandbox = false;
      defaultProfile = "openclaw";
      tabCleanup = {
        enabled = true;
        idleMinutes = 30;
        maxTabsPerSession = 10;
        sweepMinutes = 10;
      };
    };

    channels.telegram = {
      enabled = true;
      tokenFile = config.sops.secrets.openclaw-telegram-bot-token.path;
      dmPolicy = "allowlist";
      allowFrom = [ "7336229793" ];
      groupPolicy = "disabled";
    };
    commands.ownerAllowFrom = [ "telegram:7336229793" ];
    session.dmScope = "per-channel-peer";

    # The connection becomes active when Home Assistant's MCP endpoint is
    # restored on alan-home-server; keeping it here preserves one clear contract.
    mcp.servers.home-assistant = {
      enabled = true;
      url = "http://alan-home-server:8123/api/mcp/assist";
      transport = "streamable-http";
      connectionTimeoutMs = 5000;
      requestTimeoutMs = 20000;
      supportsParallelToolCalls = false;
      headers.Authorization = "Bearer \${OPENCLAW_HOME_ASSISTANT_TOKEN}";
    };
  };

  # Runtime wrappers load SOPS secrets into the process environment without
  # copying their values into the generated JSON or the Nix store.
  launcher = pkgs.writeShellScript "openclaw-gateway-start" ''
    set -euo pipefail

    export HOME=/home/buddia
    export OPENCLAW_STATE_DIR=${lib.escapeShellArg stateDir}
    export OPENCLAW_CONFIG_PATH=${lib.escapeShellArg "${stateDir}/openclaw.json"}
    export OPENCLAW_GATEWAY_TOKEN="$(${pkgs.coreutils}/bin/tr -d '\r\n' < ${lib.escapeShellArg config.sops.secrets.openclaw-gateway-token.path})"
    export OPENCLAW_HOME_ASSISTANT_TOKEN="$(${pkgs.coreutils}/bin/tr -d '\r\n' < ${lib.escapeShellArg config.sops.secrets.home-assistant-openclaw-token.path})"
    export PATH=${lib.makeBinPath [ openclawPackage ]}:/run/current-system/sw/bin

    ${pkgs.coreutils}/bin/mkdir -p \
      ${lib.escapeShellArg workspaceDir} \
      ${lib.escapeShellArg "${workspaceDir}/memory"} \
      ${lib.escapeShellArg "${stateDir}/agents/jarvis/agent"}
    ${pkgs.coreutils}/bin/install -m 0600 ${approvals} ${lib.escapeShellArg "${stateDir}/exec-approvals.json"}
    if [ ! -e ${lib.escapeShellArg "${workspaceDir}/MEMORY.md"} ]; then
      ${pkgs.coreutils}/bin/install -m 0600 ${./workspace/MEMORY.md} ${lib.escapeShellArg "${workspaceDir}/MEMORY.md"}
    fi

    exec ${lib.getExe openclawPackage} gateway run
  '';

  # The interactive command uses the same state, config, and credentials as
  # the managed gateway so diagnostics cannot inspect an accidental new profile.
  cli = pkgs.writeShellScriptBin "openclaw" ''
    set -euo pipefail

    export HOME=/home/buddia
    export OPENCLAW_STATE_DIR=${lib.escapeShellArg stateDir}
    export OPENCLAW_CONFIG_PATH=${lib.escapeShellArg "${stateDir}/openclaw.json"}
    export OPENCLAW_GATEWAY_TOKEN="$(${pkgs.coreutils}/bin/tr -d '\r\n' < ${lib.escapeShellArg config.sops.secrets.openclaw-gateway-token.path})"
    export OPENCLAW_HOME_ASSISTANT_TOKEN="$(${pkgs.coreutils}/bin/tr -d '\r\n' < ${lib.escapeShellArg config.sops.secrets.home-assistant-openclaw-token.path})"
    exec ${lib.getExe openclawPackage} "$@"
  '';
in
{
  sops.secrets = {
    openclaw-gateway-token = {
      owner = "buddia";
      mode = "0400";
    };
    openclaw-telegram-bot-token = {
      owner = "buddia";
      mode = "0400";
    };
    home-assistant-openclaw-token = {
      owner = "buddia";
      mode = "0400";
    };
  };

  users.users.buddia.linger = true;

  home-manager.users.buddia = {
    home.packages = [ cli ];
    home.file = {
      ".openclaw/openclaw.json" = {
        source = openclawConfig;
        force = true;
      };
      ".openclaw/workspaces/jarvis/AGENTS.md" = {
        source = ./workspace/AGENTS.md;
        force = true;
      };
      ".openclaw/workspaces/jarvis/HEARTBEAT.md" = {
        source = ./workspace/HEARTBEAT.md;
        force = true;
      };
      ".openclaw/workspaces/jarvis/IDENTITY.md" = {
        source = ./workspace/IDENTITY.md;
        force = true;
      };
      ".openclaw/workspaces/jarvis/SOUL.md" = {
        source = ./workspace/SOUL.md;
        force = true;
      };
      ".openclaw/workspaces/jarvis/USER.md" = {
        source = ./workspace/USER.md;
        force = true;
      };
    };

    systemd.user.services.openclaw-gateway = {
      Unit = {
        Description = "OpenClaw personal assistant gateway";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        ExecStart = launcher;
        Restart = "always";
        RestartSec = 5;
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
