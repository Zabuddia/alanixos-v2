{
  # uhid and uinput let streamed controllers appear as local input devices.
  boot.kernelModules = [ "uhid" ];

  # Permit members of the input group to use the virtual input devices.
  services.udev.extraRules = ''
    KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", GROUP="input", MODE="0660", TAG+="uaccess"
    KERNEL=="uhid", SUBSYSTEM=="misc", GROUP="input", MODE="0660", TAG+="uaccess"
  '';

  # Sunshine streams this desktop to Moonlight clients.
  services.sunshine = {
    enable = true;
    # Install the service but start it manually when streaming is wanted.
    autoStart = false;
    # WireGuard is trusted, so the service is not exposed on every interface.
    openFirewall = false;
    # Required for hardware capture on some Wayland/GPU combinations.
    capSysAdmin = true;
    settings.port = 47989;
  };
}
