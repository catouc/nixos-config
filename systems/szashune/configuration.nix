# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../modules/ssh.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "szashune"; # Define your hostname.
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";

  i18n.defaultLocale = "en_GB.utf8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.utf8";
    LC_IDENTIFICATION = "nl_NL.utf8";
    LC_MEASUREMENT = "nl_NL.utf8";
    LC_MONETARY = "nl_NL.utf8";
    LC_NAME = "nl_NL.utf8";
    LC_NUMERIC = "nl_NL.utf8";
    LC_PAPER = "nl_NL.utf8";
    LC_TELEPHONE = "nl_NL.utf8";
    LC_TIME = "nl_NL.utf8";
  };
  
  fonts = {
    fontDir.enable = true;
    fontconfig.enable = true;
    enableDefaultPackages = true;
    packages = [
      pkgs.nerdfonts
    ];
  };

  services.xserver.enable = false;

  environment.loginShellInit = ''
    [[ "$(tty)" == /dev/tty1 ]] && sway
  '';

  # Hardware Support for Wayland Sway
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
    };
    bluetooth.enable = true;
    pulseaudio.enable = false;
  };

  security.polkit.enable = true;

  # Swaylock
  security.pam.services.swaylock = {
    text = "auth include login";
  };


  # Nvidia graphics
  #services.xserver.videoDrivers = [ "nvidia" ];

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "altgr-intl";
  };

  services.printing.enable = true;
  services.blueman.enable = true;
  services.upower.enable = true;

  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  virtualisation.docker.enable = true;

  users.users.pboeschen = {
    isNormalUser = true;
    description = "Phil (Work)";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  users.users.pb = {
    isNormalUser = true;
    description = "Phil (Prv)";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  programs.steam.enable = true;

  services.globalprotect.enable = true;

  system.stateVersion = "22.05";
}
