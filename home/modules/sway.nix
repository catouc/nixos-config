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

  home.packages = with pkgs; [
    brightnessctl
    swayidle
    swaylock
    wl-clipboard
    wofi
  ];
}
