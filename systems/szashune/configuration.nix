{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../modules/boot.nix
    ../modules/locale.nix
    ../modules/mullvad.nix
    ../modules/sound.nix
    ../modules/security.nix
    ../modules/user.nix
    ../modules/windowmanager.nix

    (import ../modules/fonts.nix { pkgs = pkgs; })
    (import ../modules/fonts.nix { pkgs = pkgs; })
    (import ../modules/nix.nix { pkgs = pkgs; })
    (import ../modules/network.nix {
      networkManagerEnabled = true;
      hostName = "szashune";
    })
  ];

  networking.nftables.enable = true;
  networking.nftables.flushRuleset = true;

  hardware.nvidia.open = false;

  pb.windowmanager = {
    enable = true;
    useNvidiaVideoDriver = true;
    configFile = ../../home/configs/szashune-i3;
  };

  security.polkit.enable = true;
  pb.locale.enable = true;
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
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
