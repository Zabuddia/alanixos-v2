{ config, ... }:

{
  # This older MacBook requires the proprietary Broadcom `wl` Wi-Fi driver.
  nixpkgs.config.permittedInsecurePackages = [
    config.boot.kernelPackages.broadcom_sta.name
  ];

  hardware.enableRedistributableFirmware = true;
  boot = {
    extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
    kernelModules = [ "wl" ];
    # Prevent open Broadcom drivers from claiming the adapter before `wl`.
    blacklistedKernelModules = [
      "b43"
      "bcma"
      "brcmsmac"
      "brcmfmac"
      "ssb"
    ];
    # Works around Apple firmware behavior exposed through ACPI OS detection.
    kernelParams = [ "acpi_osi=" ];
  };
}
