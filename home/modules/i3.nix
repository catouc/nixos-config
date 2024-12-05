{ pkgs, config, lib, ... }:
let
  cfg = config.pb.home.i3;
in
{
  options.pb.home.i3 = {
    enable = lib.mkEnableOption "Enable i3 configuration management";
    configFile = lib.mkOption {
      type = lib.types.path;
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.".config/i3/config" = {
      source = cfg.configFile;
      recursive = true;
      onChange = ''
        ${pkgs.i3}/bin/i3-msg reload
      '';
    };

    home.file."polybar.ini" = {
      enable = true;
      source = ../configs/polybar.ini;
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

    home.packages = with pkgs; [
      polybar
      rofi
    ];
  };
 }


