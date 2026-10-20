{ pkgs, ... }:

{
  # Remmina is a graphical RDP, VNC, and SSH remote-desktop client.
  home-manager.users.buddia.home.packages = [ pkgs.remmina ];
}
