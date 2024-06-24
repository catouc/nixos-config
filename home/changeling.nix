{ pkgs, config, ... }:
{
  imports = [
    ./modules/terminal.nix
    (import ./modules/git.nix {
      git-email = "catouc@philipp.boeschen.me";
      url-rewrites = {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com";
        };
      };
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
      shiori
      thunderbird
    ];
  };

  pb.home.terminal = {
    enable = true;
    fontSize = 8;
  };
}
