{
  config,
  pkgs-unstable,
  ...
}:

let
  domain = "searxng.fifefin.com";
  port = 8888;
in
{
  # Keep SearXNG's session secret outside the world-readable Nix store.
  sops.secrets.searxng-secret-key = {
    owner = "searx";
    group = "searx";
    mode = "0400";
  };
  sops.templates.searxng-environment = {
    content = "SEARX_SECRET_KEY=${config.sops.placeholder.searxng-secret-key}\n";
    owner = "searx";
    group = "searx";
    mode = "0400";
  };

  # SearXNG combines results from multiple search engines without giving
  # Open WebUI or OpenClaw a commercial search-provider dependency.
  services.searx = {
    enable = true;
    package = pkgs-unstable.searxng;
    environmentFile = config.sops.templates.searxng-environment.path;
    openFirewall = false;
    settings = {
      use_default_settings = true;
      general.instance_name = "Alanix Search";
      server = {
        bind_address = "127.0.0.1";
        inherit port;
        secret_key = "$SEARX_SECRET_KEY";
        base_url = "https://${domain}/";
      };
      search.formats = [
        "html"
        "json"
      ];
    };
  };

  services.caddy.virtualHosts.${domain} = {
    logFormat = null; # Search terms belong in neither Caddy nor system logs.
    extraConfig = "reverse_proxy 127.0.0.1:${toString port}";
  };
  services.ddclient.domains = [ domain ];
}
