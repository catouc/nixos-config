{ pkgs, ... }:
let
  todo = pkgs.writeShellScriptBin "todo" ''
    #! /usr/bin/env bash
    set -uo pipefail

    touch ~/todo

    CURRENT_DATE=$(date --rfc-3339=date)
    grep "$CURRENT_DATE" ~/todo
    if [ "$?" -ne 0 ]; then
      echo "$CURRENT_DATE" >> ~/todo
    fi

    echo "$(date --rfc-3339 seconds): " >> ~/todo
    vim + ~/todo
  '';
in
{
  home.packages = with pkgs; [
    bluez
    delta
    dig
    file
    firefox
    gcc
    git
    google-chrome
    htop
    jq
    ncspot
    powertop
    ripgrep
    semver
    tmux
    todo
    unzip
    vim
    wget
    xsv
    zip
  ];

  programs.home-manager.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
