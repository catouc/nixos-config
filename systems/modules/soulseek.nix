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
  };

  config = mkIf cfg.enable {
    services.slskd = {
      enable = true;
      domain = cfg.hostName;
      environmentFile = /var/secrets/soulseek;
      settings.shares.directories = [];
      nginx = {
        enableACME = true;
        forceSSL = true;
      };
    };
  };
}
