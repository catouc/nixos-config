{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../modules/boot.nix
    ../modules/nix.nix
    ../modules/locale.nix
    ../modules/mullvad.nix
    ../modules/ntp.nix
    ../modules/security.nix
    ../modules/sound.nix
    ../modules/user.nix
    ../modules/windowmanager.nix
    ../modules/redshift.nix

    (import ../modules/fonts.nix { pkgs = pkgs; })
    (import ../modules/network.nix {
      networkManagerEnabled = true;
      hostName = "changeling";
    })
  ];

  networking.nftables.enable = true;
  networking.nftables.flushRuleset = true;
  networking.nameservers = [ "1.1.1.1" "4.4.4.4" ];

  pb.locale.enable = true;

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

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;

  hardware.bluetooth.enable = true;

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  services.upower.enable = true;
  services.fwupd.enable = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  system.stateVersion = "22.05";
}

