{
  # Invidious is a private alternative front end for YouTube.
  services.invidious = {
    enable = true;
    address = "0.0.0.0";
    port = 3001;

    # YouTube signatures require a small sandboxed JavaScript helper for some videos.
    sig-helper.enable = true;

    settings = {
      # Application-managed accounts need registration while access is private.
      registration_enabled = true;
    };
  };
}
