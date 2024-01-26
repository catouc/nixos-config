{ pkgs, config, ... }:
{
  imports = [
    (import ./modules/git.nix {
      git-email = "catouc@philipp.boeschen.me";
    })
  ];

  home = {
    username = "pb";
    homeDirectory = "/home/pb";
    stateVersion = "23.05";
  };

  home.packages = with pkgs; [
    ytdl-sub
    rtorrent
  ];
}
