{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../modules/bluetooth.nix
    ../modules/boot.nix
    ../modules/docker.nix
    ../modules/fonts.nix
    ../modules/hyprland.nix
    ../modules/jellyfin.nix
    ../modules/locales.nix
    ../modules/mullvad-vpn.nix
    ../modules/power.nix
    ../modules/printing.nix
    ../modules/ssh.nix
    ../modules/sound.nix
    ../modules/steam.nix
    ../modules/user.nix

    (import ../modules/1password.nix { username = "pboeschen"; })
    (import ../modules/nix.nix { pkgs = pkgs; })
    (import ../modules/network.nix {
      networkManagerEnabled = true;
      hostName = "changeling";
    })
    (import ../modules/polkit-agent.nix { pkgs = pkgs; })
  ];

  system.stateVersion = "22.05";
}
