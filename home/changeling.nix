{ pkgs, config, ... }:
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
      jellyfin-desktop
      mpv
    ];
  };

  services.awww = {
    enable = true;
  };

  pb.home.terminal = {
    enable = true;
  };

  pb.home.git = {
    enable = true;
    email = "catouc@philipp.boeschen.me";
    urlRewrites = [{
      from = "https://github.com";
      to = "ssh://git@github.com";
    }];
  };

  pb.home.niri = {
    enable = true;
    outputs = {
      "eDP-1" = {
        scale = 1;
        position.x = 0;
        position.y = 0;
      };
    };
  };
}
