{
  description = "Personal macOS configuration using nix-darwin, Home Manager and Flakes.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      nixpkgs,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      personal = import ./.personal.nix;

      darwinSystem = "aarch64-darwin";

    in
    {
      formatter.${darwinSystem} = nixpkgs.legacyPackages.${darwinSystem}.nixfmt-tree;

      darwinConfigurations."${personal.darwinHost}" = nix-darwin.lib.darwinSystem {

        system = darwinSystem;

        specialArgs = {
          inherit personal;
        };

        modules = [
          ./darwin/configuration.nix

          home-manager.darwinModules.home-manager
          {
            users.users.${personal.username}.home = "/Users/${personal.username}";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = {
              inherit personal;
            };

            home-manager.users.${personal.username} = import ./home;

          }
        ];
      };
    };
}
