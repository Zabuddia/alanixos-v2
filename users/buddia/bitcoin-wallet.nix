{ pkgs-unstable, ... }:

{
  # Sparrow is a desktop Bitcoin wallet and transaction-management tool.
  home-manager.users.buddia.home.packages = [ pkgs-unstable.sparrow ];
}
