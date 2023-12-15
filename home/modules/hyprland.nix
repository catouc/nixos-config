{ config, lib, pkgs, ... }:
  with lib;
  let
    cfg = config.pb.home.hyprland;

    monitorOptionType = { ... }: {
      options = {
        name = mkOption {
          type = types.str;
          description = lib.mDoc "Name of the monitor device, can be read from hyprctl monitors all";
        };

        resolution = mkOption {
          type = types.str;
          description = lib.mDoc "Resolution of the monitor";
          example = lib.literalExpression "1920x1080";
        };

        position = mkOption {
          type = types.str;
          description = "Where in the coordinate space of resolutions your monitor is supposed to show";
          example = lib.literalExpression "0x0";
        };

        scale = mkOption {
          type = types.int;
          description = "The scale to apply to the screen";
        };
      };
    };
  in {
    options.pb.home.hyprland = {
      enable = mkEnableOption "Enable custom hyprland config";

      monitors = mkOption {
        type = types.listOf (types.submodule monitorOptionType);
        default = [ ];
        description = lib.mDoc "A set of monitor options";
      };

      wallpaper = mkOption {
        type = types.str;
        default = "";
        description = "Just the config text for hyprpaper";
        example = lib.literalExpression ''
          preload = ~/Pictures/Wallpapers/tron-1.jpg
          wallpaper = DP-1,~/Pictures/Wallpapers/tron-1.jpg
        '';
      };
    };
    config = mkIf cfg.enable {
      wayland.windowManager.hyprland = {
        enable = true;
        extraConfig = ''
          exec-once = hyprpaper
          $mod = SUPER

          windowrulev2 = opacity 0.9 0.3,class:^(Alacritty)$

          bind = $mod, C, closewindow
          bind = $mod, D, exec, rofi -show run
          bind = $mod, F, fullscreen, 0
          bind = $mod, Q, exec, alacritty
          bind = $mod, S, exec, rofi -show ssh
          bind = , Print, exec, grim -g "$(slurp)"
          bind = SHIFT, Print, exec, grim -g "$(slurp)" - | wl-copy

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
          ${concatMapStringsSep "\n" (monitor: "monitor = ${monitor.name},${monitor.resolution},${monitor.position},${toString monitor.scale}") cfg.monitors}
        '';
      };

      home.file.".config/hypr/hyprpaper.conf".text = cfg.wallpaper;

      home.packages = with pkgs; [
        brightnessctl
        hyprpaper
        grim
        pamixer
        rofi
        slurp
        swaylock
        wl-clipboard
        xdg-desktop-portal-wlr
      ];

    };
  }

