{ config, lib, pkgs, ... }:
let
  cfg = config.pb.windowmanager;
in
{
  options.pb.windowmanager = {
    enable = lib.mkEnableOption "Enable my custom window manager configurations";
  };

  config = lib.mkIf cfg.enable {
    programs.niri = {
      enable = true;
    };

    xdg.portal = {
      enable = true;

      # NOTE: `configPackages` is ignored when `xdg.portal.config.niri` is defined.
      config.niri = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Access" = "gtk";
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
        "org.freedesktop.impl.portal.Notification" = "gtk";
        "org.freedesktop.impl.portal.Secret" = "gnome-keyring";
      };

      # Recommended by upstream, required for screencast support
      # https://github.com/YaLTeR/niri/wiki/Important-Software#portals
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
      ];
    };
  };
}
