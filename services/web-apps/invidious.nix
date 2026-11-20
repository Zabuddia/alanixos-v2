{ pkgs-unstable, ... }:

{
  # Invidious is a private alternative front end for YouTube.
  services.invidious = {
    enable = true;
    package = pkgs-unstable.invidious;
    address = "127.0.0.1";
    port = 3001;
    domain = "invidious.fifefin.com";

    # Companion now performs stream retrieval, replacing the older signature helper.
    sig-helper.enable = false;

    settings = {
      # Invidious uses these values when constructing public links behind Caddy.
      external_port = 443;
      https_only = true;

      # Existing accounts remain application-managed. Public registration is
      # deliberately closed now that the service is reachable from the WAN.
      registration_enabled = false;
    };
  };
}
