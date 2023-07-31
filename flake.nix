{
  description = "Phils config ";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jiwa = {
      url = "github:catouc/jiwa";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, jiwa, }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (final: prev: {jiwa = jiwa.packages.${system}.jiwa;})
        ];
      };
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        changeling = lib.nixosSystem {
          inherit system pkgs;
          modules = [
            ./systems/changeling/configuration.nix

            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.pb = {
                imports = [
		  ./home/pb.nix
		  ./home/modules/sway.nix
		];
              };
            }
          ];
        };

        fractine = lib.nixosSystem {
          inherit system pkgs;
          modules = [
            ./systems/fractine/configuration.nix

            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.pboeschen = {
                imports = [
		  ./home/pboeschen.nix
		  ./home/modules/sway.nix
		];
              };
            }
          ];
        };

        szashune = lib.nixosSystem {
          inherit system pkgs;
          modules = [
            ./systems/szashune/configuration.nix

            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.pboeschen = {
                imports = [
		  ./home/pboeschen.nix
		];
              };
              home-manager.users.pb = {
                imports = [
		  ./home/pb.nix
		];
              };
            }
          ];
        };
      };

      homeConfigurations.pb = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
	  ./home/pb.nix
	];
      };

      templates = {
        go = {
          path = ./templates/go;
          description = "My Go application template";
          welcomeText = ''
            # Go application template
            run `./setup.sh <package name>` to set this thing up properly
          '';
        };
      };
    };
}
