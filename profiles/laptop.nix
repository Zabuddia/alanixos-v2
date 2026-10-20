{
  # Firmware updates delivered through the Linux Vendor Firmware Service.
  services.fwupd.enable = true;
  # Exposes balanced, performance, and power-saver profiles.
  services.power-profiles-daemon.enable = true;
  # Prevents Intel laptops from overheating; harmless when unsupported.
  services.thermald.enable = true;
  # Makes battery and power status available to desktop applications.
  services.upower.enable = true;
  # Applies power-saving tunables automatically at boot.
  powerManagement.powertop.enable = true;
}
