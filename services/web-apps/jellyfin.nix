{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  # Jellyfin has no NixOS bind-address option because it normally stores this
  # setting in mutable network.xml. Keeping this small file declarative makes
  # the loopback-only boundary reproducible instead of relying on a web-UI edit.
  networkConfig = pkgs.writeText "jellyfin-network.xml" ''
    <?xml version="1.0" encoding="utf-8"?>
    <NetworkConfiguration>
      <InternalHttpPort>8096</InternalHttpPort>
      <PublicHttpPort>443</PublicHttpPort>
      <EnableHttps>false</EnableHttps>
      <RequireHttps>false</RequireHttps>
      <EnableIPv4>true</EnableIPv4>
      <EnableIPv6>false</EnableIPv6>
      <AutoDiscovery>false</AutoDiscovery>
      <EnableRemoteAccess>true</EnableRemoteAccess>
      <EnablePublishedServerUriByRequest>true</EnablePublishedServerUriByRequest>
      <LocalNetworkAddresses>
        <string>127.0.0.1</string>
      </LocalNetworkAddresses>
      <KnownProxies>
        <string>127.0.0.1</string>
      </KnownProxies>
    </NetworkConfiguration>
  '';
in
{
  # Jellyfin streams movies, shows, recordings, and other local video.
  services.jellyfin = {
    enable = true;
    package = pkgs-unstable.jellyfin;
    openFirewall = false;
  };

  # Libraries keep their existing paths under /home/buddia/Syncthing/media.
  users.users.${config.services.jellyfin.user}.extraGroups = [ "users" ];

  # Copy rather than symlink the store file because Jellyfin expects its config
  # directory to be writable. This runs before every Jellyfin service start.
  systemd.services.jellyfin-network-config = {
    description = "Install declarative Jellyfin network configuration";
    before = [ "jellyfin.service" ];
    requiredBy = [ "jellyfin.service" ];
    serviceConfig.Type = "oneshot";
    path = [ pkgs.coreutils ];
    script = ''
      install -D -m 0600 \
        -o ${config.services.jellyfin.user} \
        -g ${config.services.jellyfin.group} \
        ${networkConfig} \
        ${config.services.jellyfin.configDir}/network.xml
    '';
  };

  # Restart Jellyfin when the declarative network file changes so a rebuild
  # cannot leave the old listener active until the next reboot.
  systemd.services.jellyfin.restartTriggers = [ networkConfig ];
}
