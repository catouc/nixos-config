{
  description = "Phils config ";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0.tar.gz";
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

    firefly-iii-importer = {
      url = "github:catouc/firefly-iii-importer";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    gitlab-notifications = {
      url = "github:catouc/gitlab-notifications?ref=0.2.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nyaa-bulk = {
      url = "github:catouc/nyaa-bulk";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    feed-to-epub = {
      url = "github:catouc/feed-to-epub";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    lix-module,
    home-manager,
    jiwa,
    gitlab-notifications,
    nyaa-bulk,
    firefly-iii-importer,
    nixgl,
    feed-to-epub,
    ...
  }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (final: prev: { jiwa = jiwa.packages.${system}.jiwa; })
          (final: prev: { firefly-iii-importer = firefly-iii-importer.packages.${system}.default; })
          (final: prev: { gitlab-notifications = gitlab-notifications.packages.${system}.gitlab-notifications; })
          (final: prev: { nyaa-bulk = nyaa-bulk.packages.${system}.default; })
          (final: prev: { feed-to-epub = feed-to-epub.packages.${system}.default; })
          self.overlays.ytdl-sub
          self.overlays.i3-layouts
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
        i3-layouts = final: prev: {
          i3-layouts = final.callPackage ./packages/i3-layouts.nix { };
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

        kolyarut = lib.nixosSystem {
          inherit system pkgs;
          modules = [
            ./systems/kolyarut/configuration.nix
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
            lix-module.nixosModules.default

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
            lix-module.nixosModules.default
            feed-to-epub.nixosModules.default

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
          extraSpecialArgs = {
            inherit nixgl;
          };
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
        rust = {
          path = ./templates/rust;
          description = "My Rust shell template";
          welcomeText = ''
            uWu
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
