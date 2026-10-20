{ pkgs, ... }:

{
  # CUPS provides local printing and printer discovery.
  services.printing = {
    enable = true;
    browsing = true;
    drivers = with pkgs; [
      brlaser # Open driver for many Brother laser printers.
      gutenprint # Drivers for a broad range of consumer printers.
      hplip # HP printer and scanner drivers.
    ];
    webInterface = true;
  };

  # Avahi discovers printers advertised with mDNS/Bonjour on the local network.
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Presents compatible USB printers as driverless IPP devices.
  services.ipp-usb.enable = true;
  # Graphical utility for adding printers and managing queues.
  environment.systemPackages = [ pkgs.system-config-printer ];
}
