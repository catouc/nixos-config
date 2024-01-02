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
      shiori
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

    extraBinds = ''
      bind = , code:233, exec, brightnessctl set 10%+
      bind = , code:232, exec, brightnessctl set 10%-
      bind = , code:123, exec, pamixer -i 10
      bind = , code:122, exec, pamixer -d 10
      bind = , code:121, exec, pamixer -t
    '';

    wallpaper = ''
      preload = ~/Pictures/Wallpapers/Caleb1.jpg
      wallpaper = eDP-1,~/Pictures/Wallpapers/Caleb1.jpg
    '';
  };
}
