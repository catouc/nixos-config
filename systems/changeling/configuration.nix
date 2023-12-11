{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../modules/bluetooth.nix
    ../modules/boot.nix
    ../modules/docker.nix
    ../modules/hyprland.nix
    ../modules/jellyfin.nix
    ../modules/locale.nix
    ../modules/mullvad-vpn.nix
    ../modules/power.nix
    ../modules/printing.nix
    ../modules/ssh.nix
    ../modules/sound.nix
    ../modules/steam.nix
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

  system.stateVersion = "22.05";
}
