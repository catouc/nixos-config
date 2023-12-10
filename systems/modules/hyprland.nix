{ ... }:
{
  # Windowmanager, currently using Hyprland
  # Using wayland and I think those two options are toggled like this?
  services.xserver.enable = false;

  # "WLR_NO_HARDWARE_CURSORS=1" needs to be set at least on my desktop
  # so the mouse cursor is actually rendered
  environment.loginShellInit = ''
    [[ "$(tty)" == /dev/tty1 ]] && WLR_NO_HARDWARE_CURSORS=1 Hyprland
  '';

  programs.hyprland.enable = true;
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
    };
    bluetooth.enable = true;
    pulseaudio.enable = false;
  };

  security.polkit.enable = true;
  security.pam.services.swaylock = {
    text = "auth include login";
  };
}
