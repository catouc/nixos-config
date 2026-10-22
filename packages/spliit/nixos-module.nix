{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.pb.spliit;

  prismaDepsEnv = pkgs.runCommand "prisma-7-config-node-modules" {} ''
    mkdir -p $out/node_modules/prisma

    ln -s ${pkgs.prisma_7}/lib/prisma/packages/config $out/node_modules/prisma/config
  '';

  prismaDeploy = pkgs.symlinkJoin {
    name = "prisma-deploy";
    paths = [ pkgs.prisma_7 ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/prisma \
        --set PRISMA_SCHEMA_ENGINE_BINARY "${pkgs.prisma-engines_7}/bin/schema-engine" \
        --set PRISMA_QUERY_ENGINE_BINARY "${pkgs.prisma-engines_7}/bin/query-engine" \
        --set PRISMA_QUERY_ENGINE_LIBRARY "${pkgs.prisma-engines_7}/lib/libquery_engine.node" \
        --set PRISMA_FMT_BINARY "${pkgs.prisma-engines_7}/bin/prisma-fmt" \
        --set PRISMA_DISABLE_TELEMETRY "1" \
        --prefix LD_LIBRARY_PATH : "${makeLibraryPath [ pkgs.openssl ]}" \
        --prefix NODE_PATH : ${prismaDepsEnv}/node_modules \
        --set HOME "/tmp"
    '';
  };
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
        pkgs.nodejs
        pkgs.openssl
        pkgs.tsx
      ];

      environment = {
        # PRISMA_SCHEMA_ENGINE_BINARY="${pkgs.prisma-engines_7}/bin/schema-engine";
        # PRISMA_QUERY_ENGINE_BINARY="${pkgs.prisma-engines_7}/bin/query-engine";
        # PRISMA_QUERY_ENGINE_LIBRARY="${pkgs.prisma-engines_7}/lib/libquery_engine.node";
        # PRISMA_FMT_BINARY="${pkgs.prisma-engines_7}/bin/prisma-fmt";
        # LD_LIBRARY_PATH="${makeLibraryPath [ pkgs.openssl ]}";
        # PRISMA_DISABLE_TELEMETRY="1";
        # NODE_PATH="${pkgs.spliit}/share/spliit/node_modules:${pkgs.prisma_7}/lib/node_modules";
	      POSTGRES_URL_NON_POOLING="postgres://${cfg.user}@localhost/${cfg.postgresDatabaseName}?host=${cfg.postgresHost}";
	      POSTGRES_PRISMA_URL="postgres://${cfg.user}@localhost/${cfg.postgresDatabaseName}?host=${cfg.postgresHost}";
        DATABASE_URL="postgres://spliit@localhost/spliit?host=/var/run/postgresql";
      };

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${prismaDeploy}/bin/prisma migrate deploy --schema ${pkgs.spliit}/prisma/schema.prisma --config ${pkgs.spliit}/prisma/prisma.config.ts";
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
        # MemoryDenyWriteExecute="yes";
        SystemCallArchitectures="native";
      };
    };
  };
}
