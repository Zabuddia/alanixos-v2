{ pkgs-unstable, ... }:

{
  # Ungoogled Chromium provides Chromium without Google service integration.
  home-manager.users.buddia.programs.chromium = {
    enable = true;
    package = pkgs-unstable.ungoogled-chromium;
    commandLineArgs = [
      "--ozone-platform=wayland" # Use native Wayland instead of XWayland.
      # Avoid a known unreliable VA-API path while leaving other acceleration enabled.
      "--disable-features=VaapiVideoDecodeLinuxGL"
      "--homepage=about:blank"
      "--no-default-browser-check"
    ];
  };
}
