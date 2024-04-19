{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../modules/boot.nix
    ../modules/hyprland.nix
    ../modules/locale.nix
    ../modules/sound.nix
    ../modules/security.nix
    ../modules/user.nix

    (import ../modules/fonts.nix { pkgs = pkgs; })
    (import ../modules/nix.nix { pkgs = pkgs; })
    (import ../modules/network.nix {
      networkManagerEnabled = true;
      hostName = "szashune";
    })
  ];

  networking.nftables.enable = true;
  networking.nftables.flushRuleset = true;
  # based on https://discourse.nixos.org/t/connected-to-mullvadvpn-but-no-internet-connection/35803/12
  # to restore mullvad VPN DNS resolution
  networking.resolvconf.extraConfig = ''
    dynamic_order='tap[0-9]* tun[0-9]* vpn vpn[0-9]* wg* wg[0-9]* ppp[0-9]* ippp[0-9]*'
  '';

  # Nvidia graphics
  # TODO: figure out if this can be safely dropped
  services.xserver.videoDrivers = [ "nvidia" ];
  pb.hyprland = {
    enable = true;
    nvidiaGPU = true;
  };

  pb.locale.enable = true;
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

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

  programs.ssh.startAgent = true;
  programs.steam.enable = true;

  services.mullvad-vpn.enable = true;
  services.printing.enable = true;

  system.stateVersion = "22.05";
}
