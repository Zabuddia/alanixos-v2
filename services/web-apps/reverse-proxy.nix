{ lib, ... }:

let
  # This inventory is the single source of truth for public application names
  # and their loopback-only backends. Adding an application here creates both
  # its Caddy virtual host and its Cloudflare DDNS target.
  applications = {
    audiobookshelf = {
      domain = "audiobookshelf.fifefin.com";
      port = 13378;
    };
    immich = {
      domain = "immich.fifefin.com";
      port = 2283;
    };
    invidious = {
      domain = "invidious.fifefin.com";
      port = 3001;
    };
    jellyfin = {
      domain = "jellyfin.fifefin.com";
      port = 8096;
    };
    navidrome = {
      domain = "navidrome.fifefin.com";
      port = 4533;
    };
    open-webui = {
      domain = "openwebui.fifefin.com";
      port = 18080;
    };
    radicale = {
      domain = "radicale.fifefin.com";
      port = 5232;
    };
    searxng = {
      domain = "searxng.fifefin.com";
      port = 8888;
    };
    vaultwarden = {
      domain = "vaultwarden.fifefin.com";
      port = 8222;
    };
  };
in
{
  # Caddy obtains and renews public certificates automatically, redirects HTTP
  # to HTTPS, and forwards WebSockets without application-specific directives.
  services.caddy = {
    enable = true;
    email = "fife.alan@protonmail.com";
    virtualHosts = lib.mapAttrs' (
      _name: application:
      lib.nameValuePair application.domain {
        # Some applications place authentication tokens in request URLs. Keep
        # Caddy's operational journal messages but do not write request paths.
        logFormat = null;
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString application.port}
        '';
      }
    ) applications;
  };

  # Only the reverse proxy is reachable for web traffic from the physical
  # network. Every application backend is bound to loopback. wg0 normally
  # bypasses the whole firewall as a trusted interface, so express that trust
  # here with an explicit exception for Caddy: WireGuard may reach everything
  # except TCP 80 and 443.
  # extraInputRules is supported by NixOS's nftables firewall, not its legacy
  # iptables implementation, so select nftables explicitly on this server.
  networking.nftables.enable = true;
  networking.firewall = {
    trustedInterfaces = lib.mkForce [ "lo" ];
    extraInputRules = lib.mkAfter ''
      iifname != "wg0" tcp dport { 80, 443 } accept comment "public Caddy listeners"
      iifname "wg0" tcp dport { 80, 443 } reject with tcp reset comment "WAN web applications are not exposed through WireGuard"
      iifname "wg0" accept comment "trust all other WireGuard traffic"
    '';
  };

  # ddclient updates existing Cloudflare A records when the residential public
  # address changes. The WireGuard hostname is declared in services/ddns.nix.
  services.ddclient.domains = lib.mkAfter (
    map (application: application.domain) (builtins.attrValues applications)
  );
}
