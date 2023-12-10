{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../modules/bluetooth.nix
    ../modules/boot.nix
    ../modules/docker.nix
    ../modules/hyprland.nix
    ../modules/jellyfin.nix
    ../modules/mullvad-vpn.nix
    ../modules/user.nix
    ../modules/ssh.nix
    ../modules/steam.nix
    (import ../modules/common-services.nix { pkgs = pkgs; })
    (import ../modules/nix.nix { pkgs = pkgs; })
    (import ../modules/1password.nix { username = "pboeschen"; })
    (import ../modules/polkit-agent.nix { pkgs = pkgs; })
    (import ../modules/network.nix {
      networkManagerEnabled = true;
      hostName = "changeling";
    })
  ];

  system.stateVersion = "22.05";
}
