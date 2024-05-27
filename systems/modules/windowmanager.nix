{ config, lib, pkgs, ... }:
let
  cfg = config.pb.windowmanager;
in
{
  options.pb.windowmanager = {
    enable = lib.mkEnableOption "Enable my custom window manager configurations";

    useNvidiaVideoDriver = lib.mkEnableOption "Enable nvidia proprietary driver";

    configFile = lib.mkOption {
      type = lib.types.path;
      default = "";
      description = "The explicit config file to use for the window manager";
    };
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.defaultSession = "none+i3";
    services.xserver = {
      enable = true;
      desktopManager = {
        xterm.enable = false;
      };

      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
        extraPackages = with pkgs; [
          dmenu #application launcher most people use
          i3status # gives you the default i3 status bar
          i3lock #default i3 screen locker
        ];

        configFile = cfg.configFile;
      };
    };

    services.xserver.videoDrivers = lib.mkIf cfg.useNvidiaVideoDriver [ "nvidia" ];
  };
}
