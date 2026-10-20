{ config, ... }:

{
  nixpkgs.config.permittedInsecurePackages = [
    config.boot.kernelPackages.broadcom_sta.name
  ];

  hardware.enableRedistributableFirmware = true;
  boot = {
    extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
    kernelModules = [ "wl" ];
    blacklistedKernelModules = [
      "b43"
      "bcma"
      "brcmsmac"
      "brcmfmac"
      "ssb"
    ];
    kernelParams = [ "acpi_osi=" ];
  };
}
