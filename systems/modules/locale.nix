{ ... }:
{
  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_GB.utf8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.utf8";
    LC_IDENTIFICATION = "en_GB.utf8";
    LC_MEASUREMENT = "en_GB.utf8";
    LC_MONETARY = "nl_NL.utf8";
    LC_NAME = "en_GB.utf8";
    LC_NUMERIC = "de_DE.utf8";
    LC_PAPER = "en_GB.utf8";
    LC_TELEPHONE = "en_GB.utf8";
    LC_TIME = "en_GB.utf8";
  };

  # TODO: I have no idea if this works if the xserver is disabled?!
  services.xserver = {
    layout = "us";
    xkbVariant = "altgr-intl";
  };
}
