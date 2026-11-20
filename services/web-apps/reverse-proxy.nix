{
  # Individual application modules own their domain and reverse-proxy route.
  # This file contains only behavior shared by every public web application.
  services.caddy = {
    enable = true;
    email = "fife.alan@protonmail.com";
  };

  # Only Caddy's standard HTTP and HTTPS ports are opened. Application backend
  # ports remain loopback-only even though WireGuard itself is trusted.
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
