{ pkgs, lib, config, ... }:
{
  imports = [
    ./modules/terminal.nix
    ./modules/i3.nix

    (import ./modules/git.nix {
      git-email = "catouc@philipp.boeschen.me";
    })
  ];
  home = {
    username = "pb";
    homeDirectory = "/home/pb";
    stateVersion = "22.05";
    packages = with pkgs; [
      cargo
      discord
      mullvad-vpn
      gcc
      godot_4
      rustc
      rust-analyzer
      rtorrent
      thunderbird
      xivlauncher
    ];
  };

  pb.home.terminal = {
    enable = true;
  };

  pb.home.i3 = {
    enable = true;
    configFile = ./configs/szashune-i3;
  };

}

