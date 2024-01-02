# { nvidiaGPU ? false, lib, config, ... }:
{ config, lib, pkgs, ... }:
  with lib;
  let
    cfg = config.pb.hyprland;
  in {
    options.pb.hyprland = {
      enable = mkEnableOption "Enables Hyprland on system";

      monitors = mkOption {
        type = types.attrsOf;
        default = { };
        description = lib.mDoc "A set of monitor options";
      };

      nvidiaGPU = mkOption {
        type = types.bool;
        default = false;
        description = "toggles system settings for nvidia GPUs";
      };
    };

    config = mkIf cfg.enable {
      # Using wayland and I think those two options are toggled like this?
      services.xserver.enable = false;

      # "WLR_NO_HARDWARE_CURSORS=1" needs to be set at least on my desktop
      # so the mouse cursor is actually rendered
      environment.loginShellInit = ''
        [[ "$(tty)" == /dev/tty1 ]] && WLR_NO_HARDWARE_CURSORS=1 Hyprland
      '';

      programs.hyprland = {
        enable = true;
      };

      hardware = {
        opengl = {
          enable = true;
          driSupport = true;
        };

        bluetooth.enable = true;
        pulseaudio.enable = false;
      };

      hardware.nvidia = mkIf cfg.nvidiaGPU {
        modesetting.enable = true;
        powerManagement.enable = false;
        powerManagement.finegrained = false;
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };

      security.polkit.enable = true;
      security.pam.services.swaylock = {
        text = "auth include login";
      };
    };
  }

