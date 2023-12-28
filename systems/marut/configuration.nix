{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  networking.hostName = "marut";
  networking.domain = "";
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
  };

  users.groups = {
    ytdl-sub = {};
  };

  users.users = {
    root = {
      openssh.authorizedKeys.keys = [
        ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEUrXTWtqfBvZCn/SPlN0nZmhPhwvOc4M8gPeKN1b2eZ''
      ];
    };

    pb = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEUrXTWtqfBvZCn/SPlN0nZmhPhwvOc4M8gPeKN1b2eZ''
      ];
    };

    ytdl-sub = {
      isSystemUser = true;
      group = "ytdl-sub";
    };
  };

  fileSystems = {
    "/media/jellyfin/YouTube" = {
      device = "/dev/disk/by-uuid/f470f9eb-ac73-490b-ab63-861afe248452";
      fsType = "ext4";
    };
  };

  systemd.timers.ytdl-sub = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "30m";
      OnUnitActiveSec = "30m";
      Unit = "ytdl-sub.service";
    };
  };

  systemd.services.ytdl-sub = {
    script = ''
      set -euo pipefail
      ${pkgs.ytdl-sub}/bin/ytdl-sub --config /etc/ytdl-sub/config.yaml sub /etc/ytdl-sub/subcriptions.yaml
    '';

    serviceConfig = {
      Type = "oneshot";
      User = "ytdl-sub";
      WorkingDirectory = "/var/ytdl-sub";
    };
  };

  services.openssh.enable = true;
  services.jellyfin.enable = true;

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."hydra.catouc.com" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        extraConfig = "proxy_ssl_server_name on;";
      };
    };

    virtualHosts."jellyfin.catouc.com" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8096";
        extraConfig = "proxy_ssl_server_name on;";
      };
    };
  };

  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.catouc.com";
    listenHost = "127.0.0.1";
    notificationSender = "hydra@catouc.com";
    buildMachinesFiles = [];
    useSubstitutes = true;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@philipp.boeschen.me";
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  system.stateVersion = "23.05";
}
