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

    hyprland.url = "github:hyprwm/Hyprland"; 

    extrapkgs = {
      url = "github:catouc/extranixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, home-manager, jiwa, hyprland, extrapkgs, }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (final: prev: {jiwa = jiwa.packages.${system}.jiwa;})
          (final: prev: {ytdl-sub = extrapkgs.packages.${system}.ytdl-sub;})
        ];
      };
      lib = nixpkgs.lib;
      common-imports = [
        ./home/modules/common.nix
        ./home/modules/shell.nix
        ./home/modules/terminal.nix
        ./home/modules/editor.nix
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
              home-manager.users.pb = {
                imports = [
                  ./home/changeling.nix
                  hyprland.homeManagerModules.default
                ] ++ common-imports;
              };
            }
          ];
        };

        marut = lib.nixosSystem {
          inherit system pkgs;
          modules = [
            ./systems/marut/configuration.nix
            # TODO: somehow the config.pb bit is breaking, whereas the hyprland one isn't
            # maybe I'll just move all of that into this repo instead
            # extrapkgs.nixosModules.ytdl-sub

            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.pb = {
                imports = [
                  ./home/marut.nix
                  ./home/modules/shell.nix
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
              home-manager.users.pb = {
                imports = [
                  ./home/szashune.nix
                  ./home/modules/hyprland.nix
                  hyprland.homeManagerModules.default
		            ] ++ common-imports;
              };
            }
          ];
        };
      };

      homeConfigurations = {
        pb = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home/pb.nix
          ] ++ common-imports;
        };

        pboeschen = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home/pboeschen.nix
          ] ++ common-imports;
        };
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
        go-shell = {
          path = ./templates/go-shell;
          description = "My Go shell template";
          welcomeText = ''
            # Go application template
            run `./setup.sh` to set this thing up properly
          '';
        };
        terraform-shell = {
          path = ./templates/terraform-shell;
          description = "My Terraform shell template";
          welcomeText = ''
            run `./setup.sh` to set this thing up properly
          '';
        };
      };
    };
}
