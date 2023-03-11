{ pkgs, ... }:

{
  home.packages = [
    pkgs.delta
    pkgs.file
    pkgs.gcc
    pkgs.git
    pkgs.go
    pkgs.google-chrome
    pkgs.htop
    pkgs.jetbrains.goland
    pkgs.jq
    pkgs.lapce
    pkgs.ncspot
    pkgs.obsidian
    pkgs.unzip
    pkgs.vim
    pkgs.wget
    pkgs.spotify
    pkgs.semver
    pkgs.tmux
    pkgs.xsv
    pkgs.zip
  ];

  programs.home-manager.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
