{
  description = "NixOS configurations for Alan's computers";

  inputs = {
    # Stable release used for NixOS and most packages.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # Selected desktop applications use newer versions from unstable.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Declaratively manages Buddia's home-directory applications and settings.
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Decrypts host secrets at activation time without putting plaintext in the Nix store.
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
      # Build every host through the same module stack and package sources.
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
            # Modules use this to select host-specific files and inventory entries.
            hostname = name;
            # pkgs-unstable is explicit so stable remains the default package set.
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
      # Adding a machine here creates the matching `nixosConfigurations.<name>` output.
      nixosConfigurations = builtins.mapAttrs (name: system: mkHost { inherit name system; }) {
        alan-ai-server = "x86_64-linux";
        alan-home-server = "x86_64-linux";
        alan-backup-server = "x86_64-linux";
        alan-bitcoin-node = "x86_64-linux";
        alan-framework-laptop = "x86_64-linux";
        alan-main-server = "x86_64-linux";
        alan-tv-pc = "x86_64-linux";
        randy-main-server = "x86_64-linux";
        randy-tv-pc = "x86_64-linux";
      };

      # `nix fmt` formats every supported Nix file in the repository.
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
    };
}
