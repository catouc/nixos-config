{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.pb.locale;
in
{
  options.pb.locale = {
    enable = mkEnableOption "Enables locale module on system";
  };
  config = mkIf cfg.enable {
    time.timeZone = "Europe/Amsterdam";
    i18n.defaultLocale = "en_GB.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "nl_NL.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "de_DE.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };

    # TODO: I have no idea if this works if the xserver is disabled?!
    services.xserver.xkb = {
      layout = "us";
      variant = "altgr-intl";
    };
  };
}
