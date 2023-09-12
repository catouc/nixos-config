{ pkgs, config, ... }:
let
  url-rewrites = {
    "ssh://git@gitlab.booking.com/" = {
      insteadOf = "https://gitlab.booking.com/";
    };
  };

  logbook = pkgs.writeShellScriptBin "lb" ''
    #! /usr/bin/env bash
    set -euo pipefail
    vim ~/Logbook/$(date --rfc-3339=date)
  '';

  vpnLogin = pkgs.writeShellScriptBin "vpn" ''
    #! /usr/bin/env bash
    set -euo pipefail
    if ! [ $(id -u) = 0 ]; then
	echo "The script needs to be run with sudo" >&2
	exit 1
    fi

    sudo -u $SUDO_USER gpclient --start-minimized --now gp.booking.com 2> $HOME/error.log &
    until $(ip route | grep -q tun0); do sleep 1; done
    ip route del default dev tun0
    ip route add 10.0.0.0/8 dev tun0
  '';
in
{
  home.file."wireplumber.bluetooth.lua.d" = {
    enable = true;
    source = ./configs/wireplumber-51-bluez-config.lua;
    target = "./.config/wireplumber/bluetooth.lua.d/51-bluez-config.lua";
  };

  imports = [
    (import ./modules/git.nix {
      git-email = "philipp.boeschen@booking.com";
      url-rewrites = {
        "ssh://git@gitlab.booking.com/" = {
          insteadOf = "https://gitlab.booking.com/";
        };
      };
    })
  ];

  home = {
    username = "pboeschen";
    homeDirectory = "/home/pboeschen";
    stateVersion = "22.05";
    packages = with pkgs; [
      alacritty
      gcc
      globalprotect-openconnect
      jiwa
      k9s
      kubectl
      kustomize
      logbook
      #(nerdfonts.override { fonts = [ "DroidSansMono" ]; })
      okta-aws-cli
      slack
      vault
      vpnLogin
      zoom-us
    ];
  };
}
