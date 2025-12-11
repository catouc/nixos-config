{
  description = "Phils config ";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    lix-module = {
      #url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.0.tar.gz";
      url = "git+https://git.lix.systems/lix-project/nixos-module";
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

    mytube = {
      url = "github:catouc/mytube";
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

    niri.url = "github:sodiboo/niri-flake";

    feed-to-epub = {
      url = "github:catouc/feed-to-epub";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    lix-module,
    home-manager,
    mytube,
    jiwa,
    gitlab-notifications,
    nixgl,
    niri,
    feed-to-epub,
    ...
  }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          (final: prev: { mytube = mytube.packages.${system}.default; })
          (final: prev: { jiwa = jiwa.packages.${system}.jiwa; })
          (final: prev: { gitlab-notifications = gitlab-notifications.packages.${system}.gitlab-notifications; })
          (final: prev: { feed-to-epub = feed-to-epub.packages.${system}.default; })
          (final: prev: {b = feed-to-epub.packages.${system}.default; })
          ( import ./overlays/mediawiki.nix )
        ];
      };

      lib = nixpkgs.lib;
      common-imports = [
        ./home/modules/base_packages.nix
        ./home/modules/common.nix
        ./home/modules/shell.nix
        ./home/modules/terminal.nix
        ./home/modules/editor.nix
      ];
    in
    {
      nixosConfigurations = {

        kolyarut = lib.nixosSystem {
          inherit system pkgs;
          modules = [
            ./systems/kolyarut/configuration.nix
            lix-module.nixosModules.default
            niri.nixosModules.niri

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.pb = {
                imports = [
                  ./home/kolyarut.nix
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
                  ./home/gargoyle.nix
                  ./home/modules/base_packages.nix
                  ./home/modules/editor.nix
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
            niri.nixosModules.niri

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
            niri.homeModules.niri
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
