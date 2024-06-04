{ pkgs, config, lib, ... }:
let
  cfg = config.pb.home.terminal;

  terminalConfig = {
    colors = {
      bright = {
        black = "#666666";
        blue = "#E6FFFF";
        cyan = "#12848E";
        green = "#50DC81";
        magenta = "#FFFFFF";
        red = "#FA3F52";
        white = "#FFFFFF";
        yellow = "#FFFF00";
      };

      normal = {
        black = "#0C141F";
        blue = "#6FC3DF";
        cyan = "#0D5C63";
        green = "#44AF69";
        magenta = "#A23E48";
        red = "#Df740C";
        white = "#FFFFFF";
        yellow = "#FFE64D";
      };

      primary = {
        background = "#0C141F";
        foreground = "#6FC3DF";
      };

      selection = {
        background = "#F58C4B";
        text = "#6FC3DF";
      };

      cursor = {
        cursor = "#FFE64D";
        text = "#FFE64D";
      };
    };

    font = {
      size = cfg.fontSize;

      normal = {
        family = "DroidSansM Nerd Font Mono";
        style = "Regular";
      };
    };
  };
in
{
  options.pb.home.terminal = {
    enable = lib.mkEnableOption "Enable terminal configuration";
    fontSize = lib.mkOption {
      type = lib.types.ints.positive;
    };
  };

  config = lib.mkIf cfg.enable {
   home.packages = [
      pkgs.alacritty
    ];

    home.file."alacritty.toml" = {
      enable = true;
      source = (pkgs.formats.toml {}).generate "toml" terminalConfig;
      target = "./.config/alacritty/alacritty.toml";
    };
  };
 }
