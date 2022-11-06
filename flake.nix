{
  description = "Phils config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    semver-go = {
      url = "github:catouc/semver-go";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, semver-go, }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          #(final: prev: semver-go.packages.${system}.semVerGo)
        ];
      };
      lib = nixpkgs.lib;
      common-pkgs = [
        pkgs.delta
        pkgs.go
        pkgs.google-chrome
        pkgs.jetbrains.goland
        pkgs.spotify
      ];
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
                inherit common-pkgs;
              };
              home-manager.users.pb = {
                imports = [ ./home/pb.nix ];
              };
            }
          ];
        };

        fractine = lib.nixosSystem {
          inherit system pkgs;
          modules = [
            ./systems/changeling/configuration.nix

            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit common-pkgs;
              };
              home-manager.users.pboeschen = {
                imports = [ ./home/pboeschen.nix ];
              };
            }
          ];
        };
      };
    };
}
