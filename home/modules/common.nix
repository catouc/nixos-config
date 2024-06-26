{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bluez
    delta
    dig
    file
    firefox
    git
    htop
    jq
    powertop
    ripgrep
    semver
    tmux
    unzip
    vim
    wget
    xsv
    xclip
    zip
  ];

  programs.home-manager.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
