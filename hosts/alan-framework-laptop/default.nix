{
  imports = [
    ./hardware-configuration.nix
    ../../profiles/base.nix
    ../../profiles/desktop.nix
    ../../profiles/laptop.nix
    ../../services/tailscale.nix
    ../../users/buddia.nix
  ];

  networking.hostName = "alan-framework-laptop";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # BIOS 3.05 exposes an unwired AMD ACP/PDM microphone on this model.
  boot.blacklistedKernelModules = [
    "snd_acp70"
    "snd_acp_pci"
  ];

  services.pipewire.wireplumber.extraConfig."51-framework-internal-mic" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          { "node.name" = "alsa_input.pci-0000_c1_00.6.analog-stereo"; }
        ];
        actions.update-props = {
          "api.alsa.soft-mixer" = true;
          "api.alsa.disable-mixer-path" = true;
        };
      }
    ];
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 20480;
    }
  ];

  # Keep this at the release used for the machine's first NixOS installation.
  system.stateVersion = "25.11";
}
