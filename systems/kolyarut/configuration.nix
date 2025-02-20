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
      hostName = "kolyarut";
    })
  ];

  networking.nftables.enable = true;
  networking.nftables.flushRuleset = true;

  pb.locale.enable = true;
  pb.windowmanager = {
    enable = true;
    configFile = ../../home/configs/kolyarut-i3;
  };

  programs.ssh.startAgent = true;

  hardware.bluetooth.enable = true;

  services.upower.enable = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  environment.systemPackages = with pkgs; [
    feed-to-epub
  ];

  system.stateVersion = "22.05";
}
