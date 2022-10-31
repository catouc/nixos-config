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
      git-email = "catouc@philipp.boeschen.me";
    in {
      nixosConfigurations = {
        changeling = lib.nixosSystem {
          inherit system pkgs;
          modules = [
            ./systems/changeling/configuration.nix

            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit user;
                inherit git-email;
              };
              home-manager.users.${user} = {
                imports = [ ./home/home.nix ];
              };
            }
          ];
        };
      };
    };
}
