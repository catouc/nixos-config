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

      refreshRate = mkOption {
        type = types.str;
        description = lib.mDoc "Refresh rate of the monitor";
        default = "60";
        example = lib.literalExpression "60";
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
in
{
  options.pb.home.hyprland = {
    enable = mkEnableOption "Enable custom hyprland config";

    extraBinds = mkOption {
      type = types.lines;
      default = "";
      description = "A number of extra binds, useful for binding function keys on different devices separately";
    };

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
        exec-once = [workspace 1 silent] alacritty
        exec-once = [workspace 2 silent] firefox
        $mod = SUPER

        windowrulev2 = opacity 0.9 0.3,class:^(Alacritty)$
        windowrulev2 = size 720 640,title:(Project\ Settings\ \(project\.godot\))
        windowrulev2 = center 1,title:(Project\ Settings\ \(project\.godot\))

        bind = $mod, C, killactive
        bind = $mod, L, exec, swaylock
        bind = $mod, D, exec, rofi -show run
        bind = $mod, F, fullscreen, 0
        bind = $mod, Q, exec, alacritty
        bind = $mod, S, exec, rofi -show ssh
        bind = , Print, exec, grim -g "$(slurp)"
        bind = SHIFT, Print, exec, grim -g "$(slurp)" - | wl-copy
        ${cfg.extraBinds}

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
        ${concatMapStringsSep "\n" (monitor: "monitor = ${monitor.name},${monitor.resolution}@${monitor.refreshRate},${monitor.position},${toString monitor.scale}") cfg.monitors}
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

