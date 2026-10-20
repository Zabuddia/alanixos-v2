{ pkgs, ... }:

{
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

  systemd.user.services.framework-internal-mic-gain = {
    description = "Set Framework internal microphone gain";
    wantedBy = [ "default.target" ];
    wants = [ "wireplumber.service" ];
    after = [ "wireplumber.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.alsa-utils}/bin/amixer --card Generic_1 set 'Internal Mic' cap
      ${pkgs.alsa-utils}/bin/amixer --card Generic_1 cset name='Internal Mic Boost Volume' 0,0
      ${pkgs.alsa-utils}/bin/amixer --card Generic_1 cset name='Capture Volume' 30,30
    '';
  };
}
