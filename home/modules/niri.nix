{ pkgs, config, lib, ... }:
let
  cfg = config.pb.home.niri;
in
{
  imports = [
    ./waybar.nix
  ];

  options.pb.home.niri = {
    enable = lib.mkEnableOption "Enable niri configuration";

    outputs = lib.mkOption {
      type = lib.types.attrs;
      description = lib.literalExpression "Sets specific output settings acording to https://github.com/YaLTeR/niri/wiki/Configuration:-Outputs";
      default = {};
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      brightnessctl
      rofi
      sway-contrib.grimshot
      xwayland-satellite
    ];

    home.file."${config.xdg.configHome}/rofi/tron.rasi" = {
      enable = true;
      source = ../configs/tron.rasi;
    };

    pb.home.waybar.enable = true;

    programs.niri = {
      settings = {
        outputs = {} // cfg.outputs;
        #  "eDP-1" = {
        #    mode.width = 2880;
        #    mode.height = 1920;
        #    mode.refresh = 120.0;
        #    position.x = 0;
        #    position.y = 0;
        #  };

        input.touchpad.natural-scroll = false;
        layout.gaps = 8;

        binds = with config.lib.niri.actions; let
          sh = spawn "sh" "-c";
        in
        {
          "Mod+Return".action.spawn = ["ghostty"];
          "Mod+d".action.spawn = ["rofi" "-display-drun" ">" "-show" "drun"];
          "Mod+s".action.spawn = ["rofi" "-show" "ssh"];
          "Mod+Alt+l".action.spawn = ["/bin/swaylock"];
          "Mod+Shift+Slash".action = show-hotkey-overlay;

          "Mod+q".action = close-window;

          "Mod+h".action = focus-column-left;
          "Mod+j".action = focus-window-down;
          "Mod+k".action = focus-window-up;
          "Mod+l".action = focus-column-right;

          "Mod+Ctrl+h".action = move-column-left;
          "Mod+Ctrl+j".action = move-window-down;
          "Mod+Ctrl+k".action = move-window-up;
          "Mod+Ctrl+l".action = move-column-right;

          "Mod+Shift+h".action = focus-monitor-left;
          "Mod+Shift+j".action = focus-monitor-down;
          "Mod+Shift+k".action = focus-monitor-up;
          "Mod+Shift+l".action = focus-monitor-right;
          "Mod+Shift+c".action = center-column;

          "Mod+Shift+Ctrl+h".action = move-column-to-monitor-left;
          "Mod+Shift+Ctrl+j".action = move-column-to-monitor-down;
          "Mod+Shift+Ctrl+k".action = move-column-to-monitor-up;
          "Mod+Shift+Ctrl+l".action = move-column-to-monitor-right;

          "Mod+Comma".action = consume-window-into-column;
          "Mod+Period".action = expel-window-from-column;
          "Mod+BracketLeft".action = consume-or-expel-window-left;
          "Mod+BracketRight".action = consume-or-expel-window-right;

          "Mod+Tab".action = focus-workspace-previous;

          "Mod+1".action = focus-workspace 1;
          "Mod+2".action = focus-workspace 2;
          "Mod+3".action = focus-workspace 3;
          "Mod+4".action = focus-workspace 4;
          "Mod+5".action = focus-workspace 5;
          "Mod+6".action = focus-workspace 6;
          "Mod+7".action = focus-workspace 7;
          "Mod+8".action = focus-workspace 8;
          "Mod+9".action = focus-workspace 9;

          "Mod+Ctrl+1".action.move-column-to-workspace = 1;
          "Mod+Ctrl+2".action.move-column-to-workspace = 2;
          "Mod+Ctrl+3".action.move-column-to-workspace = 3;
          "Mod+Ctrl+4".action.move-column-to-workspace = 4;
          "Mod+Ctrl+5".action.move-column-to-workspace = 5;
          "Mod+Ctrl+6".action.move-column-to-workspace = 6;
          "Mod+Ctrl+7".action.move-column-to-workspace = 7;
          "Mod+Ctrl+8".action.move-column-to-workspace = 8;
          "Mod+Ctrl+9".action.move-column-to-workspace = 9;

          "Mod+Shift+1".action.move-window-to-workspace = 1;
          "Mod+Shift+2".action.move-window-to-workspace = 2;
          "Mod+Shift+3".action.move-window-to-workspace = 3;
          "Mod+Shift+4".action.move-window-to-workspace = 4;
          "Mod+Shift+5".action.move-window-to-workspace = 5;
          "Mod+Shift+6".action.move-window-to-workspace = 6;
          "Mod+Shift+7".action.move-window-to-workspace = 7;
          "Mod+Shift+8".action.move-window-to-workspace = 8;
          "Mod+Shift+9".action.move-window-to-workspace = 9;

          "Mod+f".action = maximize-column;
          "Mod+Shift+f".action = fullscreen-window;
          "Mod+Minus".action.set-column-width = "-10%";
          "Mod+Equal".action.set-column-width = "+10%";
          "Mod+Shift+Minus".action.set-window-height = "-10%";
          "Mod+Shift+Equal".action.set-window-height = "+10%";

          "XF86AudioRaiseVolume".action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"];
          "XF86AudioLowerVolume".action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"];
          "XF86AudioMute".action.spawn = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];

          "XF86MonBrightnessUp".action = sh "brightnessctl set 10%+";
          "XF86MonBrightnessDown".action = sh "brightnessctl set 10%-";

          "Mod+Shift+p".action.spawn = ["grimshot" "save" "area"];

          "XF86AudioMicMute" = {
            allow-when-locked = true;
            action = sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          };

          "Mod+Shift+e".action = quit;
        };

        spawn-at-startup = [
         { command = ["waybar"]; }
         { command = ["xwayland-satellite"]; }
        ];

        environment = {
          DISPLAY = ":0";
        };
      };
    };
  };
}
