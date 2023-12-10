{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
  };

  description = "";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem ( system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        build = pkgs.buildGoModule {
          pname = "replace";
          version = "v0.1.0";
          modSha256 = pkgs.lib.fakeSha256;
          vendorHash = null;
          src = ./.;
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
              go
              gopls
              golangci-lint
              gotools
              delve
            ];
          };
        };
      }
    );
}

