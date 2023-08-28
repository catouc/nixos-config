{ pkgs, ...}:
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
      };
    };
  };

  home.packages = [
    pkgs.brightnessctl
    pkgs.swaylock
    pkgs.swayidle
    pkgs.wl-clipboard
    # pkgs.mako notification daemon
    pkgs.wofi
  ];
}
