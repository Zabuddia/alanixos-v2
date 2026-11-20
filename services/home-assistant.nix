{ config, ... }:

{
  # Home Assistant keeps device registries, history, and UI-managed integration
  # state in /var/lib/hass while Nix owns the stable configuration below.
  services.home-assistant = {
    enable = true;
    configWritable = false;

    # Components configured through the UI still need their Python dependencies
    # included in Home Assistant's otherwise immutable package environment.
    extraComponents = [
      "bluetooth" # Discovers nearby Bluetooth smart-home devices.
      "default_config" # Standard dashboard, history, logbook, and mobile-app features.
      "esphome" # Integrates ESPHome-based sensors and controllers.
      "improv_ble" # Provisions compatible devices over Bluetooth.
      "local_calendar" # Stores calendars locally in Home Assistant.
      "local_todo" # Stores local task lists.
      "mcp_server" # Gives OpenClaw a scoped Home Assistant tool endpoint.
      "met" # Supplies local weather data from the Norwegian Meteorological Institute.
      "mqtt" # Supports MQTT integrations when an authenticated broker is added.
      "piper" # Connects to the Piper Wyoming text-to-speech service.
      "systemmonitor" # Exposes selected host resource sensors.
      "time_date" # Provides time and date sensor entities.
      "uptime" # Reports how long Home Assistant has been running.
      "version" # Reports installed and available Home Assistant versions.
      "wake_on_lan" # Allows automations to wake computers by MAC address.
      "wyoming" # Discovers the AI server's speech services.
      "zha" # Controls Zigbee devices through a local coordinator.
    ];

    config = {
      # Loads Home Assistant's standard integrations without duplicating each one.
      default_config = { };
      homeassistant = {
        name = "Home";
        time_zone = config.time.timeZone;
        unit_system = "us_customary";
        # This WireGuard hostname is independent of the server's physical LAN.
        internal_url = "http://alan-home-server:8123";
      };
      http = {
        server_host = [
          "0.0.0.0"
          "::"
        ];
        server_port = 8123;
      };
    };
  };

  # USB Zigbee coordinators and similar serial adapters normally use dialout.
  users.users.hass.extraGroups = [ "dialout" ];

  # mDNS lets Home Assistant find local devices whose addresses are assigned by DHCP.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Port 8123 is not opened globally. It remains reachable through trusted wg0,
  # while moving this host to another physical network does not expose the UI there.
}
