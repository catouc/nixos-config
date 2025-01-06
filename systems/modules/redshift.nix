{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.pb.redshift;
in
{
  options.pb.redshift = {
    enable = mkEnableOption "Enable redshift";
    longitude = mkOption {
      type = types.float;
      default = 4.897070;
    };
    latitude = mkOption {
      type = types.float;
      default = 52.377956;
    };
    dayTemperature = mkOption {
      type = types.int;
      default = 5500;
    };
    nightTemperature = mkOption {
      type = types.int;
      default = 3500;
    };
  };

  config = mkIf cfg.enable {
    location = {
      latitude = cfg.latitude;
      longitude = cfg.longitude;
    };
    services.redshift = {
      enable = true;
      brightness = {
        day = "1";
        night = "1";
      };
      temperature = {
        day = cfg.dayTemperature;
        night = cfg.nightTemperature;
      };
    };
  };
}
