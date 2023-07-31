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

  home.file."alacritty.yml" = {
    enable = true;
    source = ../configs/alacritty.yml;
    target = "./.config/alacritty/alacritty.yml";
  };

  home.packages = [
    pkgs.swaylock
    pkgs.swayidle
    pkgs.wl-clipboard
    # pkgs.mako notification daemon
    pkgs.alacritty
    pkgs.wofi
  ];
}
