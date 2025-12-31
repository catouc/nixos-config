{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bluez
    firefox
    git
    htop
    jq
  ];

  programs.home-manager.enable = true;
}
