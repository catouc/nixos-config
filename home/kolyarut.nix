{ pkgs, config, ... }:
{
  imports = [
    ./modules/i3.nix
    ./modules/terminal.nix
    ./modules/git.nix
  ];

  home = {
    username = "pb";
    homeDirectory = "/home/pb";
    stateVersion = "22.05";
    packages = with pkgs; [
      calibre
      discord
      mpv
      thunderbird
    ];
  };

  pb.home.terminal = {
    enable = true;
  };

  pb.home.i3 = {
    enable = true;
    configFile = ./configs/kolyarut-i3;
    polybarName = "kolyarut";
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
