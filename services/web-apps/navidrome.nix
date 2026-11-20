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
      Address = "0.0.0.0";
      Port = 4533;
      MusicFolder = "/home/buddia/Syncthing/media/music";
      Scanner.Schedule = "@every 5m";
      Scanner.PurgeMissing = "always";
      EnableInsightsCollector = false;
    };
  };

  users.users.${config.services.navidrome.user}.extraGroups = [ "users" ];
}
