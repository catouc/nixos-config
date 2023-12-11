{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../modules/boot.nix
    ../modules/docker.nix
    ../modules/fonts.nix
    ../modules/hyprland.nix
    ../modules/locale.nix
    ../modules/printing.nix
    ../modules/ssh.nix
    ../modules/sound.nix
    ../modules/steam.nix
    ../modules/user.nix

    (import ../modules/nix.nix { pkgs = pkgs; })
    (import ../modules/network.nix {
      networkManagerEnabled = true;
      hostName = "szashune";
    })
  ];

  fileSystems = {
    "/home/pb/.local/share/Steam" = {
      device = "/dev/disk/by-uuid/9a986255-abe7-412d-a3ce-091381ed8abb";
      fsType = "ext4";
    };
  };

  # Nvidia graphics
  # TODO: figure out if this can be safely dropped
  services.xserver.videoDrivers = [ "nvidia" ];
  pb.hyprland = {
    enable = true;
    nvidiaGPU = true;
  };

  system.stateVersion = "22.05";
}
