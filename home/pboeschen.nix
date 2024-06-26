{ pkgs, ... }:
let
  logbook = pkgs.writeShellScriptBin "lb" ''
    #! /usr/bin/env bash
    set -euo pipefail
    vim ~/Logbook/$(date --rfc-3339=date)
  '';
in
{
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

  home.file."wireplumber.bluetooth.lua.d" = {
    enable = true;
    source = ./configs/wireplumber-51-bluez-config.lua;
    target = "./.config/wireplumber/bluetooth.lua.d/51-bluez-config.lua";
  };

  pb.home.terminal = {
    enable = true;
    fontSize = 11;
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  programs.gpg.enable = true;

  home = {
    username = "pboeschen";
    homeDirectory = "/home/pboeschen";
    stateVersion = "22.05";
    packages = (with pkgs; [
      alacritty
      gitlab-notifications
      google-chrome
      jiwa
      k9s
      kubectl
      kustomize
      (nerdfonts.override { fonts = [ "DroidSansMono" ]; })
      okta-aws-cli
      slack
      vault
      zoom-us
    ]) ++ [
      logbook
    ];
  };
}
