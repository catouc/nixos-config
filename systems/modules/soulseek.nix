{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.pb.slskd;
in
{
  options.pb.slskd = {
    enable = mkEnableOption "Enable slskd under nginx";

    hostName = mkOption {
      type = types.str;
      default = "";
      description = "DNS name of the final server";
    };

    shares = mkOption {
      type = types.listOf types.path;
      default = [];
      description = "List of shares";
    };
  };

  config = mkIf cfg.enable {
    services.slskd = {
      enable = true;
      domain = cfg.hostName;
      environmentFile = /var/secrets/soulseek;
      settings.shares.directories = forEach cfg.shares (x: builtins.toString x);
      openFirewall = true;
      nginx = {
        enableACME = true;
        forceSSL = true;
      };
    };
  };
}
