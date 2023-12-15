{ pkgs, config, ... }:
{
  imports = [
    ./modules/hyprland.nix
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
      rustc
      rtorrent
      thunderbird
    ];
  };

  pb.home.hyprland = {
    enable = true;
    monitors = [{
      name = "eDP-1";
      resolution = "1920x1080";
      position = "0x0";
      scale = 1;
    }];

    wallpaper = ''
      preload = ~/Pictures/Wallpapers/Caleb1.png
      wallpaper = eDP-1,~/Pictures/Wallpapers/Caleb1.png
    '';
  };

}
