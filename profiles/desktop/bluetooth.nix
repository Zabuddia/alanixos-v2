{
  # Bluetooth is opt-in for computers that use controllers, audio devices, or
  # Home Assistant's local Bluetooth integrations.
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    input.General.ClassicBondedOnly = false;
  };
  services.blueman.enable = true; # Graphical Bluetooth manager and tray applet.
}
