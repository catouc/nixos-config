{ pkgs, lib, config, ... }:
{
  imports = [
    ./modules/niri.nix
    ./modules/waybar.nix
    ./modules/terminal.nix
    ./modules/git.nix
  ];
  home = {
    username = "pb";
    homeDirectory = "/home/pb";
    stateVersion = "22.05";
    packages = with pkgs; [
      discord
      mullvad-vpn
      thunderbird
      obsidian
    ];
  };

  pb.home.terminal = {
    enable = true;
  };

  pb.home.niri = {
    enable = true;
  };

  pb.home.git = {
    enable = true;
    email = "catouc@philipp.boeschen.me";
    urlRewrites = [];
  };
}

