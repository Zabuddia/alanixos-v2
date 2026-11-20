{
  # Use NixOS's native Wyoming modules so service users, persistent directories,
  # command escaping, and systemd hardening remain maintained by Nixpkgs.
  services.wyoming = {
    # Faster Whisper converts speech to text for Home Assistant Assist.
    faster-whisper.servers.english = {
      enable = true;
      uri = "tcp://0.0.0.0:10300";
      sttLibrary = "faster-whisper";
      model = "large-v3-turbo";
      language = "en";
      device = "cpu";
      beamSize = 1;
      zeroconf.enable = false;
      extraArgs = [
        "--compute-type"
        "int8"
        "--cpu-threads"
        "16"
      ];
    };

    # Piper generates local speech without sending text to a cloud provider.
    piper.servers.english = {
      enable = true;
      uri = "tcp://0.0.0.0:10200";
      voice = "en_US-lessac-medium";
      zeroconf.enable = false;
    };
  };
}
