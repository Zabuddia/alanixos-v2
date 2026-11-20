{
  config,
  pkgs-unstable,
  ...
}:

{
  # Navidrome provides a web player and Subsonic-compatible API for music.
  services.navidrome = {
    enable = true;
    package = pkgs-unstable.navidrome;
    openFirewall = false;
    settings = {
      # Caddy is the only network-facing process; the application stays private.
      Address = "127.0.0.1";
      Port = 4533;
      MusicFolder = "/home/buddia/Syncthing/media/music";
      Scanner.Schedule = "@every 5m";
      Scanner.PurgeMissing = "always";
      EnableInsightsCollector = false;
    };
  };

  users.users.${config.services.navidrome.user}.extraGroups = [ "users" ];
}
