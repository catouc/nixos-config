{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.pb.onecastle;
in
{
  options.pb.onecastle = {
    enable = mkEnableOption "Enable the onecastle web service";

    port = mkOption {
      type = types.port;
      default = 8080;
      example = 8080;
      description = "The port for the web app to listen to";
    };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      example = "127.0.0.1";
      description = "The host to bind to";
    };

    user = mkOption {
      type = types.str;
      default = "onecastle";
      example = "onecastle";
      description = "The user to run this service under";
    };

    group = mkOption {
      type = types.str;
      default = "onecastle";
      example = "onecastle";
      description = "The group to run this service under";
    };

    postgresHost = mkOption {
      type = types.str;
      default = "/var/run/postgresql";
      description = "the host override for postgres, defaults to the unix socket";
    };

    postgresDatabaseName = mkOption {
      type = types.str;
      default = "onecastle";
      example = "onecastle";
      description = "The name of the database to connect to";
    };

    uploadDir = mkOption {
      type = types.str;
      default = "/srv/onecastle/uploads";
      example = "/srv/onecastle/uploads";
      description = "The directory where we store all of the webserver uploads";
    };
  };

  config = mkIf cfg.enable {
    users.users = {
      ${cfg.user} = {
        isSystemUser = true;
        group = "${cfg.group}";
        linger = true;
      };
    };

    users.groups.${cfg.group} = {};

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "${cfg.postgresDatabaseName}" ];
      ensureUsers = [
        {
          name = cfg.user;
          ensureDBOwnership = true;
        }
      ];
    };

    systemd.tmpfiles.rules = [
      "d ${toString cfg.uploadDir} 0775 ${cfg.user} ${cfg.group} -"
    ];

    systemd.services.onecastle = {
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.onecastle}/bin/server -addr ${toString cfg.host}:${toString cfg.port} -db \"user=${cfg.user} dbname=${cfg.postgresDatabaseName} host=${cfg.postgresHost} sslmode=disable\" -uploads ${cfg.uploadDir} -frontendDir ${pkgs.onecastle}/frontend";
        User = cfg.user;
        Group = cfg.group;

        CapabilityBoundingSet="";
        LockPersonality="yes";
        NoNewPrivileges = true;
        PrivateDevices = "yes";
        PrivateTmp = "yes";
        PrivateUsers="yes";
        ProcSubset="pid";
        ProtectClock="yes";
        ProtectControlGroups = "strict";
        ProtectHome="yes";
        ProtectHostname="yes";
        ProtectKernelLogs="yes";
        ProtectKernelModules = "yes";
        ProtectKernelTunables = "yes";
        ProtectProc="invisible";
        ProtectSystem = "strict";
        RemoveIPC="yes";
        RestrictNamespaces="yes";
        RestrictRealtime="yes";
        RestrictSUIDSGID = "yes";
        SystemCallErrorNumber="EPERM";
        SystemCallFilter="@system-service";
        SystemCallArchitectures="native";
      };
    };
  };
}
