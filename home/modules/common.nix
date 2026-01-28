{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bluez
    firefox
    git
    htop
    jq
    feishin
  ];

  programs.home-manager.enable = true;
}
