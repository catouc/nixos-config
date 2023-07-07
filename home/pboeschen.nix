{ config, pkgs, ... }:
let
  url-rewrites = {
    "ssh://git@gitlab.booking.com/" = {
      insteadOf = "https://gitlab.booking.com/";
    };
  };

  vpnLogin = pkgs.writeShellScriptBin "vpn" ''
    gpclient --start-minimized --now gp.booking.com 2> ~/error.log &
    until $(ip route | grep tun0); do sleep 1; done
    sudo ip route del default dev tun0
    sudo ip route add 10.0.0.0/8 dev tun0
  '';
in
{

  imports = [
    (import modules/common.nix)
    (import modules/shell.nix)
    (import modules/editor.nix)
    (import modules/git.nix {
      git-email = "philipp.boeschen@booking.com";
      inherit url-rewrites;
    })
  ];

  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      # Use kitty as default terminal
      terminal = "alacritty"; 
      input = {
	"type:touchpad" = {
	  tap = "enabled"; 
	  natural_scroll = "enabled"; 
	};
      };
      startup = [
        # Launch Firefox on start
        {command = "firefox";}
      ];
    };
  };

  home.file."alacritty.yml" = {
    enable = true;
    source = ./configs/alacritty.yml;
    target = "./.config/alacritty/alacritty.yml";
  };

  home = {
    username = "pboeschen";
    homeDirectory = "/home/pboeschen";
    stateVersion = "22.05";
    packages = [
      pkgs.gcc
      pkgs.globalprotect-openconnect
      pkgs.jiwa
      pkgs.k9s
      pkgs.kubectl
      pkgs.kustomize
      pkgs.slack
      pkgs.zoom-us
      vpnLogin
      pkgs.zoom-us
      # sway
      pkgs.swaylock
      pkgs.swayidle
      pkgs.wl-clipboard
      # pkgs.mako notification daemon
      pkgs.alacritty
      pkgs.wofi
      (pkgs.nerdfonts.override { fonts = [ "DroidSansMono" ]; })
    ];
  };
}
