{ pkgs, ... }:

{
  # Node.js runs JavaScript tooling and applications outside the browser.
  home-manager.users.buddia = {
    home.packages = [ pkgs.nodejs ];
    # Install global npm tools under the user home instead of requiring sudo.
    home.sessionVariables = {
      NPM_CONFIG_PREFIX = "/home/buddia/.local";
      NODE_PATH = "/home/buddia/.local/lib/node_modules";
    };
  };
}
