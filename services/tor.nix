{
  # Local applications may opt into Tor through SOCKS5 at 127.0.0.1:9050.
  services.tor = {
    enable = true;
    client = {
      enable = true;
      socksListenAddress = {
        # Separate circuits by destination to reduce cross-site correlation.
        IsolateDestAddr = true;
        addr = "127.0.0.1";
        port = 9050;
      };
    };
  };
}
