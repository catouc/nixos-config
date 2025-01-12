{ pkgs, config, lib, ... }:
let
  cfg = config.pb.home.terminal;

  palette = [
    "0=#0C141F"
    "1=#Df740C"
    "2=#44AF69"
    "3=#FFE64D"
    "4=#6FC3DF"
    "5=#A23E48"
    "6=#0D5C63"
    "7=#FFFFFF"
    "8=#666666"
    "9=#FA3F52"
    "10=#50DC81"
    "11=#FFFF00"
    "12=#E6FFFF"
    "13=#FFFFFF"
    "14=#12848E"
    "15=#FFFFFF"
  ];

  theme = ''
    background=#0C141F
    foreground=#6FC3DF
    cursor-color=#FFE64D
    selection-foreground=#6FC3DF
    selection-background=#F58C4B
    ${lib.concatStringsSep "\n" (map(x: "palette = "+x) palette)}
  '';
in
{
  options.pb.home.terminal = {
    enable = lib.mkEnableOption "Enable terminal configuration";
    fontSize = lib.mkOption {
      type = lib.types.ints.positive;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      settings = {
        window-decoration = false;
        theme = "Tron";
      };
    };

    xdg.configFile."ghostty/themes/Tron" = {
      enable = true;
      text = theme;
    };
  };
 }
