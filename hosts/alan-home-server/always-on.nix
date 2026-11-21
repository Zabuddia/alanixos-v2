{
  # Keep firmware, thermal, and battery reporting support without enabling
  # portable-laptop power profiles that are inappropriate for a server.
  services.fwupd.enable = true;
  services.thermald.enable = true;
  services.upower.enable = true;

  # The older MacBook's fan needs active control during continuous operation,
  # especially while the lid is closed.
  services.mbpfan.enable = true;

  # Closing the lid must not interrupt Home Assistant or WireGuard.
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  # Disable every systemd sleep path so applications and users cannot suspend
  # or hibernate this always-on server accidentally.
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
  };
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };
}
