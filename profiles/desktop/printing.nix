{ pkgs, ... }:

{
  services.printing = {
    enable = true;
    browsing = true;
    drivers = with pkgs; [
      brlaser
      gutenprint
      hplip
    ];
    webInterface = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.ipp-usb.enable = true;
  environment.systemPackages = [ pkgs.system-config-printer ];
}
