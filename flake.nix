{
  description = "NixOS configurations for Alan's computers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.7.0";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      home-manager,
      nixpkgs,
      nixpkgs-unstable,
      sops-nix,
      ...
    }:
    let
      mkHost =
        {
          name,
          system ? "x86_64-linux",
        }:
        let
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            hostname = name;
            inherit inputs pkgs-unstable;
          };
          modules = [
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            ./hosts/${name}
          ];
        };
    in
    {
      nixosConfigurations = builtins.mapAttrs (name: system: mkHost { inherit name system; }) {
        alan-big-nixos = "x86_64-linux";
        alan-framework = "x86_64-linux";
        alan-framework-laptop = "x86_64-linux";
        alan-home = "x86_64-linux";
        alan-node = "x86_64-linux";
        alan-optiplex = "x86_64-linux";
        alan-tv = "x86_64-linux";
        fife-tv = "x86_64-linux";
        randy-big-nixos = "x86_64-linux";
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
    };
}
