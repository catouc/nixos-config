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
      private-git-vars = {
        git-email = "catouc@philipp.boeschen.me";
        url-rewrites = {};
      };
      work-git-vars = {
        git-email = "philipp.boeschen@booking.com";
        url-rewrites = {
          "ssh://git@gitlab.booking.com/" = {
            insteadOf = "https://gitlab.booking.com/";
          };
	};
      };
      common-imports = [
	./home/modules/common.nix
	./home/modules/shell.nix
	./home/modules/terminal.nix
	./home/modules/editor.nix
	./home/modules/git.nix
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
	        # extend this with "attrSet1 // attrSet2" 
	        extraSpecialArgs = private-git-vars;
                imports = [
		  ./home/pb.nix
		  ./home/modules/sway.nix
		] ++ common-imports;
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
	        # extend this with "attrSet1 // attrSet2" 
	        extraSpecialArgs = work-git-vars;
                imports = [
		  ./home/pboeschen.nix
		  ./home/modules/sway.nix
		] ++ common-imports;
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
	        # extend this with "attrSet1 // attrSet2" 
	        extraSpecialArgs = work-git-vars;
                imports = [
		  ./home/pboeschen.nix
		] ++ common-imports;
              };
              home-manager.users.pb = {
	        # extend this with "attrSet1 // attrSet2" 
	        extraSpecialArgs = private-git-vars;
                imports = [
		  ./home/pb.nix
		] ++ common-imports;
              };
            }
          ];
        };
      };

      homeConfigurations.pb = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
	# extend this with "attrSet1 // attrSet2" 
	extraSpecialArgs = private-git-vars;
        modules = [
	  ./home/pb.nix
	] ++ common-imports;
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
