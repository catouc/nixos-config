{
  description = "Phils config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        changeling = lib.nixosSystem {
          inherit system;
          modules = [
            ./systems/changeling/configuration.nix
          ];
        };
      };
    };
}
