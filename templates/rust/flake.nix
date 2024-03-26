{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
  };

  description = "";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        build = pkgs.rustPlatform.buildRustPackage {
          pname = "replace";
          version = "v0.1.0";
          src = ./.;
          cargoSha256 = "";
        };
      in
      rec {
        packages = {
          replace = build;
          default = build;
        };

        devShells = {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              cargo
              rustc
              rust-analyzer
            ];
          };
        };
      }
    );
}

