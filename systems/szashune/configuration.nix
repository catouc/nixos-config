{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../modules/boot.nix
    ../modules/hyprland.nix
    ../modules/locale.nix
    ../modules/sound.nix
    ../modules/user.nix

    (import ../modules/fonts.nix { pkgs = pkgs; })
    (import ../modules/nix.nix { pkgs = pkgs; })
    (import ../modules/network.nix {
      networkManagerEnabled = true;
      hostName = "szashune";
    })
  ];

  # Nvidia graphics
  # TODO: figure out if this can be safely dropped
  services.xserver.videoDrivers = [ "nvidia" ];
  pb.hyprland= {
    enable = true;
    nvidiaGPU = true;
  };

  fileSystems = {
    "/home/pb/.local/share/Steam" = {
      device = "/dev/disk/by-uuid/9a986255-abe7-412d-a3ce-091381ed8abb";
      fsType = "ext4";
    };
  };

  programs.ssh.startAgent = true;
  programs.steam.enable = true;
  
  services.mullvad-vpn.enable = true;
  services.printing.enable = true;

  virtualisation.docker.enable = true;

  system.stateVersion = "22.05";
}
