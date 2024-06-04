{ pkgs, lib, config, ... }:
{
  imports = [
    ./modules/terminal.nix
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
      mullvad-vpn
      gcc
      godot_4
      rustc
      rtorrent
      thunderbird
      xivlauncher
    ];
  };

  home.file.".config/i3" = {
    source = ./configs/szashune-i3;
    onChange = ''
      ${pkgs.i3}/bin/i3-msg reload
    '';
  };

  pb.home.terminal = {
    enable = true;
    fontSize = 11;
  };
}

