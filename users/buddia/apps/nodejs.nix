{ pkgs, ... }:

{
  home-manager.users.buddia = {
    home.packages = [ pkgs.nodejs ];
    home.sessionVariables = {
      NPM_CONFIG_PREFIX = "/home/buddia/.local";
      NODE_PATH = "/home/buddia/.local/lib/node_modules";
    };
  };
}
