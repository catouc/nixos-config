{
  description = "Phils config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;
      user = "pb";
    in {
      nixosConfigurations = {
        changeling = lib.nixosSystem {
          inherit system;
          modules = [
            ./systems/changeling/configuration.nix

            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit user; };
              home-manager.users.${user} = {
                imports = [ ./home/home.nix ];
              };
            }
          ];
        };
      };

      homeManagerConfig = {
        inherit system pkgs;
        username = "pb";
        homeDirectory = "/home/pb";
        configuration = {
          imports = [
            ./home/home.nix
          ];
        };
      };
    };
}
