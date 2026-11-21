{ pkgs-unstable, ... }:

let
  domain = "forgejo.fifefin.com";
  port = 3000;
in
{
  # Forgejo hosts Git repositories and provides their web interface. Accounts,
  # repositories, issues, and other mutable state remain in /var/lib/forgejo.
  services.forgejo = {
    enable = true;
    package = pkgs-unstable.forgejo;
    lfs.enable = true;
    settings = {
      server = {
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = port;
        DOMAIN = domain;
        ROOT_URL = "https://${domain}/";
      };
      service.DISABLE_REGISTRATION = true;
      session.COOKIE_SECURE = true;
    };
  };

  services.caddy.virtualHosts.${domain} = {
    logFormat = null; # Repository names and private paths stay out of access logs.
    extraConfig = "reverse_proxy 127.0.0.1:${toString port}";
  };
  services.ddclient.domains = [ domain ];
}
