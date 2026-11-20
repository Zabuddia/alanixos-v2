{
  config,
  pkgs-unstable,
  ...
}:

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
        port = 8888;
        secret_key = "$SEARX_SECRET_KEY";
        base_url = "https://searxng.fifefin.com/";
      };
      search.formats = [
        "html"
        "json"
      ];
    };
  };
}
