{ pkgs, ... }:

{
  home-manager.users.buddia.home.packages = with pkgs; [
    gparted # Graphical disk partition editor.
    usbimager # Writes operating-system images to USB drives and SD cards.
    wdisplays # Graphical Wayland monitor arrangement tool.
  ];
}
