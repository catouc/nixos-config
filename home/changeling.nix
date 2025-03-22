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
      mpv
      thunderbird
    ];
  };

  pb.home.terminal = {
    enable = true;
  };

  pb.home.i3 = {
    enable = true;
    configFile = ./configs/changeling-i3;
    polybarName = "changeling";
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
