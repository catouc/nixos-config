{
  description = "Phils config ";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    lix = {
      url = "git+https://git@git.lix.systems/lix-project/lix?ref=refs/tags/2.90-beta.1";
      flake = false;
    };

    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
      inputs.lix.follows = "lix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jiwa = {
      url = "github:catouc/jiwa";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nyaa-bulk = {
      url = "github:catouc/nyaa-bulk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, lix-module, home-manager, jiwa, nyaa-bulk, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (final: prev: { jiwa = jiwa.packages.${system}.jiwa; })
          (final: prev: { nyaa-bulk = nyaa-bulk.packages.${system}.default; })
          self.overlays.ytdl-sub
          self.overlays.firefly-iii
        ];
      };

      lib = nixpkgs.lib;
      common-imports = [
        ./home/modules/common.nix
        ./home/modules/shell.nix
        ./home/modules/terminal.nix
        ./home/modules/editor.nix
      ];
    in
    {
      overlays = {
        ytdl-sub = final: prev: {
          ytdl-sub = final.callPackage ./packages/ytdl-sub.nix { };
        };
        firefly-iii = final: prev: {
          firefly-iii = final.callPackage ./packages/firefly-iii.nix { };
        };
      };
      nixosConfigurations = {
        changeling = lib.nixosSystem {
          inherit system pkgs;
          modules = [
            ./systems/changeling/configuration.nix
            lix-module.nixosModules.default

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.pb = {
                imports = [
                  ./home/changeling.nix
                ] ++ common-imports;
              };
            }
          ];
        };

        marut = lib.nixosSystem {
          inherit system pkgs;
          #extraArgs = { inherit extrapkgs; };
          modules = [
            ./systems/marut/configuration.nix
            home-manager.nixosModules.home-manager
            {
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

        gargoyle = lib.nixosSystem {
          inherit system pkgs;
          modules = [
            ./systems/gargoyle/configuration.nix
            home-manager.nixosModules.home-manager
            {
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
            lix-module.nixosModules.default

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.pb = {
                imports = [
                  ./home/szashune.nix
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

      formatter.${system} = pkgs.nixpkgs-fmt;

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nixd
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
