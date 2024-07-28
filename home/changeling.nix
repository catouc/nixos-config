{ pkgs, config, ... }:
{
  imports = [
    ./modules/terminal.nix
    (import ./modules/git.nix {
      git-email = "catouc@philipp.boeschen.me";
      url-rewrites = {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com";
        };
      };
    })
  ];

  home = {
    username = "pb";
    homeDirectory = "/home/pb";
    stateVersion = "22.05";
    packages = with pkgs; [
      cargo
      mullvad-vpn
      gcc
      godot_4
      rustc
      rtorrent
      shiori
      thunderbird
    ];
  };

  pb.home.terminal = {
    enable = true;
    fontSize = 8;
  };

  home.file.".config/i3" = {
    source = ./configs/changeling-i3;
    onChange = ''
      ${pkgs.i3}/bin/i3-msg reload
    '';
  };

  home.file."polybar.ini" = {
    enable = true;
    source = ./configs/polybar.ini;
    target = "./.config/polybar/config.ini";
  };

  home.file."polybar-launch" = {
    enable = true;
    text = ''
    #/usr/bin/env bash
    polybar-msg cmd quit
    echo "---" | tee -a /var/log/polybar/polybar.log
    polybar changeling 2>&1 | tee -a /var/log/polybar/polybar.log & disown
    echo "Bars launched..."
    '';
    target = "./.config/polybar/launch";
    executable = true;
  };
}
