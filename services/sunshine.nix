{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Sunshine stores credentials in its runtime state, so reapply the encrypted
  # declarative value before each start to prevent Web UI configuration drift.
  applyCredentials = pkgs.writeShellScript "sunshine-apply-credentials" ''
    set -euo pipefail

    password="$(${pkgs.coreutils}/bin/tr -d '\n' < ${lib.escapeShellArg config.sops.secrets.sunshine-password.path})"
    if [ -z "$password" ]; then
      echo "Sunshine password is empty" >&2
      exit 1
    fi

    exec ${lib.getExe pkgs.sunshine} --creds buddia "$password"
  '';
in
{
  sops.secrets.sunshine-password = {
    owner = "buddia";
    mode = "0400";
  };

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

  systemd.user.services.sunshine.serviceConfig.ExecStartPre = [ applyCredentials ];
}
