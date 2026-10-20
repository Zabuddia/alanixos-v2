{
  boot.kernelModules = [ "uhid" ];

  services.udev.extraRules = ''
    KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", GROUP="input", MODE="0660", TAG+="uaccess"
    KERNEL=="uhid", SUBSYSTEM=="misc", GROUP="input", MODE="0660", TAG+="uaccess"
  '';

  services.sunshine = {
    enable = true;
    autoStart = false;
    openFirewall = false;
    capSysAdmin = true;
    settings.port = 47989;
  };
}
