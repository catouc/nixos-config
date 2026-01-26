{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.pb.spliit;
in
{
  options.pb.spliit = {
    enable = mkEnableOption "Enable the spliit web service";

    port = mkOption {
      type = types.port;
      default = 3000;
      example = 3000;
      description = "The port for the web app to listen to, will set the \"PORT\" env var.";
    };

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      example = "127.0.0.1";
      description = "The host to bind to, will set the \"HOSTNAME\" env var";
    };

    user = mkOption {
      type = types.str;
      default = "spliit";
      example = "spliit";
      description = "The user to run this service under";
    };

    group = mkOption {
      type = types.str;
      default = "spliit";
      example = "spliit";
      description = "The group to run this service under";
    };

    postgresHost = mkOption {
      type = types.str;
      default = "/var/run/postgresql";
      description = "the host override for postgres, defaults to the unix socket";
    };

    postgresDatabaseName = mkOption {
      type = types.str;
      default = "spliit";
      example = "spliit";
      description = "The name of the database to connect to";
    };
  };

  config = mkIf cfg.enable {  
    systemd.services.spliit-init = {
      wantedBy = [ "spliit.service" ];

      path = [
        pkgs.openssl
      ];

      environment = {
        PRISMA_SCHEMA_ENGINE_BINARY="${pkgs.prisma-engines_6}/bin/schema-engine";
        PRISMA_QUERY_ENGINE_BINARY="${pkgs.prisma-engines_6}/bin/query-engine";
        PRISMA_QUERY_ENGINE_LIBRARY="${pkgs.prisma-engines_6}/lib/libquery_engine.node";
        PRISMA_FMT_BINARY="${pkgs.prisma-engines_6}/bin/prisma-fmt";
    	  LD_LIBRARY_PATH="${makeLibraryPath [ pkgs.openssl ]}";
        PRISMA_DISABLE_TELEMETRY="1";
	      POSTGRES_URL_NON_POOLING="postgres://${cfg.user}@localhost/${cfg.postgresDatabaseName}?host=${cfg.postgresHost}";
	      POSTGRES_PRISMA_URL="postgres://${cfg.user}@localhost/${cfg.postgresDatabaseName}?host=${cfg.postgresHost}";
      };

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.prisma_6}/bin/prisma migrate deploy --schema ${pkgs.spliit}/prisma/schema.prisma";
        User = cfg.user;
        Group = cfg.group;
      };
    };

    systemd.services.spliit = {
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      environment = {
        PORT = toString cfg.port;
        HOSTNAME = toString cfg.host;
	      POSTGRES_URL_NON_POOLING="postgres://${cfg.user}@localhost/${cfg.postgresDatabaseName}?host=${cfg.postgresHost}";
	      POSTGRES_PRISMA_URL="postgres://${cfg.user}@localhost/${cfg.postgresDatabaseName}?host=${cfg.postgresHost}";
      };

      serviceConfig = {
        ExecStart = "${pkgs.spliit}/bin/spliit";
        User = cfg.user;
        Group = cfg.group;
      };
    };
  };
}
