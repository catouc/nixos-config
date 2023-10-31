{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bluez
    delta
    dig
    file
    firefox
    gcc
    git
    google-chrome
    htop
    jq
    ncspot
    powertop
    ripgrep
    semver
    tmux
    unzip
    vim
    wget
    xsv
    zip
  ];

  programs.home-manager.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
