{ pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      exec = hyprpaper
      $mod = SUPER

      windowrulev2 = opacity 0.9 0.3,class:^(Alacritty)$

      bind = $mod, C, closewindow
      bind = $mod, D, exec, rofi -show run
      bind = $mod, F, fullscreen, 0
      bind = $mod, Q, exec, alacritty
      # move workspaces
      ${builtins.concatStringsSep "\n" (builtins.genList (
        x:
          let
            ws = builtins.toString(x);
          in ''
            bind = $mod, ${ws}, workspace, ${ws}
            #bind = $mod, ${ws}, exec, hyprctl hyprpaper wallpaper "DP-1,~/Pictures/Wallpapers/tron-1.jpg"
            bind = SUPER_SHIFT, ${ws}, movetoworkspacesilent, ${ws}
          ''
      ) 10)}
    '';
  };

  home.file = {
    ".config/hypr/hyprpaper.conf".text = ''
      preload = ~/Pictures/Wallpapers/tron-1.jpg
      wallpaper = DP-1,~/Pictures/Wallpapers/tron-1.jpg
    '';
  };

  home.packages = with pkgs; [
    hyprpaper
    rofi
    xdg-desktop-portal-wlr
  ];
}
