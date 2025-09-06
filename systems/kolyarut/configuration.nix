{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../modules/boot.nix
    ../modules/locale.nix
    ../modules/mullvad.nix
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
    enable = false;
    configFile = ../../home/configs/kolyarut-i3;
  };

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

  hardware.bluetooth.enable = true;

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
  services.tailscale.enable = true;

  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  system.stateVersion = "22.05";
}
