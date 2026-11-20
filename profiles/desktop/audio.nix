{ pkgs, ... }:

{
  # PipeWire handles audio; its PulseAudio compatibility supports older applications.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Real-time scheduling prevents audio dropouts under system load.
  security.rtkit.enable = true;
  environment.systemPackages = [ pkgs.alsa-utils ]; # Audio controls and diagnostics.
}
