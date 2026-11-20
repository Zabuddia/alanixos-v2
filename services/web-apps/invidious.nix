{ pkgs-unstable, ... }:

{
  # Invidious is a private alternative front end for YouTube.
  services.invidious = {
    enable = true;
    package = pkgs-unstable.invidious;
    address = "0.0.0.0";
    port = 3001;

    # Companion now performs stream retrieval, replacing the older signature helper.
    sig-helper.enable = false;

    settings = {
      # Application-managed accounts need registration while access is private.
      registration_enabled = true;
    };
  };
}
