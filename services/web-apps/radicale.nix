{
  config,
  pkgs-unstable,
  ...
}:

{
  # Radicale is a lightweight CalDAV and CardDAV server. Unlike the other
  # applications, it has no account-management UI, so its account is declarative.
  sops.secrets.radicale-password = {
    owner = config.services.radicale.user;
    group = config.services.radicale.group;
    mode = "0400";
  };
  sops.templates.radicale-users = {
    content = "buddia:${config.sops.placeholder.radicale-password}\n";
    owner = config.services.radicale.user;
    group = config.services.radicale.group;
    mode = "0400";
  };

  services.radicale = {
    enable = true;
    package = pkgs-unstable.radicale;
    settings = {
      server.hosts = [
        "0.0.0.0:5232"
        "[::]:5232"
      ];
      auth = {
        type = "htpasswd";
        htpasswd_filename = config.sops.templates.radicale-users.path;
        # The plaintext password exists only in the root-owned SOPS source and
        # this runtime file; WireGuard encrypts authentication on the network.
        htpasswd_encryption = "plain";
      };
      storage.filesystem_folder = "/var/lib/radicale/collections";
    };

    # A user may manage only their own calendars and address books.
    rights = {
      root = {
        user = ".+";
        collection = "";
        permissions = "R";
      };
      principal = {
        user = ".+";
        collection = "{user}";
        permissions = "RW";
      };
      calendars = {
        user = ".+";
        collection = "{user}/[^/]+";
        permissions = "rw";
      };
    };
  };

  systemd.services.radicale = {
    after = [ "sops-nix.service" ];
    wants = [ "sops-nix.service" ];
  };
}
