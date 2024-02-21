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
      hostName = "changeling";
    })
  ];

  pb.hyprland = {
    enable = true;
  };

  pb.locale.enable = true;
  networking.wireguard.enable = true;

  programs.ssh.startAgent = true;
  programs.steam.enable = true;
  
  services.blueman.enable = true;
  services.mullvad-vpn.enable = true;
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
  services.printing.enable = true;
  services.upower.enable = true;

  virtualisation.docker.enable = true;

  system.stateVersion = "22.05";
}
