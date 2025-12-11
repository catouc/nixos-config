{ pkgs, config, ... }:
{
  imports = [
    ./modules/git.nix
  ];

  home = {
    username = "pb";
    homeDirectory = "/home/pb";
    stateVersion = "22.05";
    packages = with pkgs; [
    ];
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
