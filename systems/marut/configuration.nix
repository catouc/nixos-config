{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  networking.hostName = "marut";
  networking.domain = "";
  networking.nftables.enable = true;
  networking.nftables.flushRuleset = true;
  networking.nftables.tables.excludeFromVPN = {
    family = "inet";
    name = "excludeFromVPN";
    content = ''
      chain allowIncoming {
	type filter hook input priority -100; policy accept;
	tcp dport 22 meta mark set 0x00000f41 meta mark set 0x6d6f6c65
	tcp dport 443 meta mark set 0x00000f41 meta mark set 0x6d6f6c65
      }

      chain allowOutgoing {
        type route hook output priority -100; policy accept;
	tcp sport 22 meta mark set 0x00000f41 meta mark set 0x6d6f6c65
	tcp sport 443 meta mark set 0x00000f41 meta mark set 0x6d6f6c65
      }
    '';
  };
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
  };

  users.groups = {
    ytdl-sub = {};
  };

  users.users = {
    pb = {
      isNormalUser = true;
      extraGroups = [ "wheel" "jellyfin" ];
      openssh.authorizedKeys.keys = [
        ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEUrXTWtqfBvZCn/SPlN0nZmhPhwvOc4M8gPeKN1b2eZ''
	      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINY+KfRjOhVNBHU0so8CI3zoXFQAvYtgCxKsAmQYjfSE''
	      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPRVGs2ui3gP3O8TgQP6+UJIQZrwipZgcDltOdIXvT4Y''
      ];
    };

    ytdl-sub = {
      isSystemUser = true;
      group = "ytdl-sub";
    };
  };

  fileSystems = {
    "/media/jellyfin" = {
      device = "/dev/disk/by-uuid/f470f9eb-ac73-490b-ab63-861afe248452";
      fsType = "ext4";
    };
  };

  systemd.timers.ytdl-sub = {
    enable = false;
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

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.jellyfin.enable = true;
  services.mullvad-vpn.enable = true;

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
    enable = false;
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
    htop
    vim
    tmux
  ];

  system.stateVersion = "23.05";
}
