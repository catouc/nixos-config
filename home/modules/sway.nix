{ pkgs, ... }:
{
  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      terminal = "alacritty";
      input = {
        "type:touchpad" = {
          tap = "enabled";
          natural_scroll = "enabled";
        };
        "type:pointer" = {
          pointer_accel = "-0.5";
        };
      };
    };
  };

  home.packages = with pkgs; [
    brightnessctl
    pamixer
    swayidle
    swaylock
    wl-clipboard
    wofi
  ];
}
