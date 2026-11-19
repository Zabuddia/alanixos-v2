{ lib, pkgs, ... }:

let
  mkVoiceService = stateDirectory: command: {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      DynamicUser = true;
      StateDirectory = stateDirectory;
      StateDirectoryMode = "0750";
      ExecStart = lib.escapeShellArgs command;
      Restart = "on-failure";
      RestartSec = 5;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
    };
  };
in
{
  # Wyoming is the protocol Home Assistant uses for remote speech services.
  systemd.services = {
    wyoming-faster-whisper = mkVoiceService "wyoming-whisper" [
      (lib.getExe pkgs.wyoming-faster-whisper)
      "--uri"
      "tcp://0.0.0.0:10300"
      "--stt-library"
      "faster-whisper"
      "--model"
      "large-v3-turbo"
      "--language"
      "en"
      "--device"
      "cpu"
      "--compute-type"
      "int8"
      "--cpu-threads"
      "16"
      "--beam-size"
      "1"
      "--data-dir"
      "/var/lib/wyoming-whisper"
      "--download-dir"
      "/var/lib/wyoming-whisper"
    ];

    wyoming-piper = mkVoiceService "wyoming-piper" [
      (lib.getExe pkgs.wyoming-piper)
      "--uri"
      "tcp://0.0.0.0:10200"
      "--voice"
      "en_US-lessac-medium"
      "--data-dir"
      "/var/lib/wyoming-piper"
      "--download-dir"
      "/var/lib/wyoming-piper"
    ];
  };
}
