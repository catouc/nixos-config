{ pkgs, ... }:
{
  home.packages = with pkgs; [
    bluez
    firefox
    obsidian
    powertop
  ];

  programs.home-manager.enable = true;
}
