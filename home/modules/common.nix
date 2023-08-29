{ pkgs, ... }:

{
  home.packages = [
    pkgs.bluez
    pkgs.delta
    pkgs.dig
    pkgs.file
    pkgs.gcc
    pkgs.git
    pkgs.google-chrome
    pkgs.htop
    pkgs.jq
    pkgs.ncspot
    pkgs.ripgrep
    pkgs.unzip
    pkgs.vim
    pkgs.wget
    pkgs.semver
    pkgs.tmux
    pkgs.xsv
    pkgs.zip
  ];

  programs.home-manager.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
