{ pkgs, config, lib, ... }:
let
  cfg = config.pb.home.waybar;
in
{
  options.pb.home.waybar = {
    enable = lib.mkEnableOption "Enable waybar";
  }; 

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;

      style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: Source Code Pro;
      }
      window#waybar {
        background: #0C141F;
        color: #6FC3DF;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #disk,
      #temperature,
      #backlight,
      #network,
      #wireplumber,
      #custom-media,
      #tray,
      #mode,
      #idle_inhibitor,
      #scratchpad,
      #power-profiles-daemon,
      #mpd {
          padding: 0 10px;
      }
      '';

      settings = {
        mainBar = {
          position = "bottom";
          layer = "top";
          height = 25;
          # modules-left = [ "niri/workspaces" ];
          modules-center = [ "clock" ];
          modules-right = [ "network" "battery" ];

          battery = {
            states = {
              warning = 30;
              critical = 15;
            };

            format = "{capacity}% {icon}";
            format-full = "{capacity}% {icon}";
            format-charging = "{capacity}% ";
            format-plugged = "{capacity}% ";
            format-alt = "{capacity}% {icon}";
            format-icons = ["" "" "" "" ""];
          };

          clock = {
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            format = "{:%Y-%m-%d %H:%M}";
          };

          cpu = {
            format = "{usage}% ";
            tooltip = false;
          };

          network = {
            format-wifi = "  {essid} ({signalStrength}%)";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
          };
        };
      };
    };
  };
}
