{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../modules/boot.nix
    ../modules/nix.nix
    ../modules/locale.nix
    ../modules/mullvad.nix
    ../modules/security.nix
    ../modules/sound.nix
    ../modules/user.nix
    ../modules/windowmanager.nix
    ../modules/redshift.nix

    (import ../modules/fonts.nix { pkgs = pkgs; })
    (import ../modules/network.nix {
      networkManagerEnabled = true;
      hostName = "kolyarut";
    })
  ];

  networking.nftables.enable = true;
  networking.nftables.flushRuleset = true;
  networking.nameservers = [ "1.1.1.1" "4.4.4.4" ];

  pb.locale.enable = true;
  pb.windowmanager = {
    enable = false;
    configFile = ../../home/configs/kolyarut-i3;
  };

  pb.redshift.enable = false;

  pb.mullvad = {
    enable = true;
    portBypasses = [ 22 ];
    localHostBypasses = [
      {
        ipv4="192.168.178.0/24";
        ports=[ 22 443 ];
      }
    ];
  };

  # Conflicts with ssh.startAgent somehow
  # TODO: Investigate if I can just turn off all of gnome?
  services.gnome.gcr-ssh-agent.enable = false;
  programs.ssh.startAgent = true;
  programs.niri = {
    enable = true;
  };

  programs.steam.enable = false;

  hardware.bluetooth.enable = true;

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  services.gvfs.enable = true;
  services.upower.enable = true;
  services.fwupd.enable = true;
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

  system.stateVersion = "22.05";
}
