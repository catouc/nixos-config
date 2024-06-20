{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../modules/boot.nix
    ../modules/locale.nix
    ../modules/security.nix
    ../modules/sound.nix
    ../modules/user.nix
    ../modules/windowmanager.nix

    (import ../modules/fonts.nix { pkgs = pkgs; })
    (import ../modules/nix.nix { pkgs = pkgs; })
    (import ../modules/network.nix {
      networkManagerEnabled = true;
      hostName = "changeling";
    })
  ];

  pb.windowmanager = {
    enable = true;
    configFile = ../../home/configs/changeling-i3;
  };

  pb.locale.enable = true;
  networking.wireguard.enable = true;

  programs.ssh.startAgent = true;
  programs.steam.enable = true;

  services.blueman.enable = true;
  hardware.bluetooth.enable = true;
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
  services.printing.enable = true;
  services.upower.enable = true;
  services.tailscale.enable = true;

  virtualisation.docker.enable = true;

  system.stateVersion = "22.05";
}
