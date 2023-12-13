{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "marut";
  networking.domain = "";
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };

  services.openssh.enable = true;
  programs.ssh.startAgent = true;
  environment.systemPackages = with pkgs; [
    git
    vim
  ];
  users.users.root.openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEUrXTWtqfBvZCn/SPlN0nZmhPhwvOc4M8gPeKN1b2eZ'' ];

  users.groups.downloaders = {};
  users.groups.ytdl-sub = {};

  users.users.pb = {
    isNormalUser = true;
    extraGroups = [ "wheel" "downloaders" ];
    openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEUrXTWtqfBvZCn/SPlN0nZmhPhwvOc4M8gPeKN1b2eZ'' ];
  };

  users.users.ytdl-sub = {
    isSystemUser = true;
    group = "ytdl-sub";
    extraGroups = [ "downloaders" ];
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
    };
  };

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

  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@philipp.boeschen.me";
  };

  services.jellyfin.enable = true;

  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.catouc.com";
    listenHost = "127.0.0.1";
    notificationSender = "hydra@catouc.com";
    buildMachinesFiles = [];
    useSubstitutes = true;
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  system.stateVersion = "23.05";
}
