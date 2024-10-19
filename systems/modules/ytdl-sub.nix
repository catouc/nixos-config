{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.pb.ytdl-sub;
in
{
  options.pb.ytdl-sub = {
    enable = mkEnableOption "Enables the systemd setup for ytdl-sub";

    logsDir = mkOption {
      type = types.path;
      default = "/var/log/ytdl-sub";
      description = "Path for the logs of ytdl-sub";
    };
  };

  config = mkIf cfg.enable {
    users.groups.ytdl-sub = { };
    users.users.ytdl-sub = {
      isSystemUser = true;
      group = "ytdl-sub";
    };

    environment.etc."ytdl-sub-configuration" = {
      target = ''
        configuration:
          ffmpeg_path: "${pkgs.ffmpeg}/bin/ffmpeg"
          ffmpeg_path: "${pkgs.ffmpeg}/bin/ffprobe"
          persist_logs:
            logs_directory: ${cfg.logsDir}
            keep_successful_logs: False
      '';
    };

    #configFile = pkgs.writeTextFile {
    #  name = "config";
    #  text = ''
    #  '';
    #};

    systemd.timers.ytdl-sub = {
      enable = false;
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "30m";
        OnUnitActiveSec = "30m";
        Unit = "ytdl-sub.service";
      };
    };

    systemd.services.ytdl-sub = {
      script = ''
        set -euo pipefail
        ${pkgs.ytdl-sub}/bin/ytdl-sub --config /etc/ytdl-sub/config.yaml sub /etc/ytdl-sub/subcriptions.yaml
      '';

      serviceConfig = {
        Type = "oneshot";
        User = "ytdl-sub";
        WorkingDirectory = "/var/ytdl-sub";
      };
    };
  };
}
