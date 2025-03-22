{ pkgs, lib, config, ... }:
{
  imports = [
    ./modules/terminal.nix
    ./modules/i3.nix
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

  pb.home.i3 = {
    enable = true;
    configFile = ./configs/szashune-i3;
    polybarName = "szashune";
  };

  pb.home.git = {
    enable = true;
    email = "catouc@philipp.boeschen.me";
    urlRewrites = [{
      from = "https://github.com";
      to = "ssh://git@github.com";
    }];
  };
}

