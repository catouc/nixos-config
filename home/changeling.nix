{ pkgs, config, ... }:
{
  imports = [
    ./modules/i3.nix
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
  };
}
