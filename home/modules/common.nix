{ pkgs, ... }:

{
  home.packages = [
    pkgs.delta
    pkgs.go
    pkgs.google-chrome
    pkgs.jetbrains.goland
    pkgs.spotify
  ];

  programs.home-manager.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
