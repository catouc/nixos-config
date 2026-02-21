{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../modules/boot.nix
    ../modules/nix.nix
    ../modules/locale.nix
    ../modules/mullvad.nix
    ../modules/ntp.nix
    ../modules/sound.nix
    ../modules/security.nix
    ../modules/user.nix
    ../modules/redshift.nix
    ../modules/windowmanager.nix

    (import ../modules/fonts.nix { pkgs = pkgs; })
    (import ../modules/fonts.nix { pkgs = pkgs; })
    (import ../modules/network.nix {
      networkManagerEnabled = true;
      hostName = "szashune";
    })
  ];

  networking.nftables.enable = true;
  networking.nftables.flushRuleset = true;

  services.xserver.videoDrivers = ["nvidia"];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaSettings = true;
  };

  pb.windowmanager = {
    enable = false;
    useNvidiaVideoDriver = true;
    configFile = ../../home/configs/szashune-i3;
  };

  # Conflicts with ssh.startAgent somehow
  # TODO: Investigate if I can just turn off all of gnome?
  services.gnome.gcr-ssh-agent.enable = false;
  programs.ssh.startAgent = true;

  programs.niri = {
    enable = true;
  };

  security.polkit.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  pb.redshift.enable = true;

  fileSystems = {
    "/home/pb/.local/share/Steam" = {
      device = "/dev/disk/by-uuid/9a986255-abe7-412d-a3ce-091381ed8abb";
      fsType = "ext4";
    };
    "/mnt/media" = {
      device = "/dev/disk/by-uuid/7a4a22e6-2a7e-4b78-a12e-e7a18148c9bb";
      fsType = "ext4";
    };
  };

  programs.steam.enable = true;
  services.mullvad-vpn.enable = true;

  system.stateVersion = "22.05";
}
