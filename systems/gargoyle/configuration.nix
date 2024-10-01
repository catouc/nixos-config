# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

      ../modules/mullvad.nix
      ../modules/photoprism.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;
  boot.loader.grub.device = "nodev";

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "media" ];

  networking.hostName = "gargoyle";
  networking.hostId = "7789dc7b";
  users.groups = {
    "media" = {};
  };

  networking.nftables.enable = true;
  networking.nftables.flushRuleset = true;
  networking.firewall = {
    enable = true;

    trustedInterfaces = [ "tailscale0" ];
    allowedTCPPorts = [ 22 80 443 ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  users.users = {
    pb = {
      isNormalUser = true;
      extraGroups = [ "wheel" "media" ];
      openssh.authorizedKeys.keys = [
        ''sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILbWTzMhSpruetqZrxqKuGbZSdjPBtT+utpLScb4y3obAAAABHNzaDo=''
        ''sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIOlJaLeMqxg7P+2lBzSjEbSf6tthaHiHD8IrOlTkFaNQAAAABHNzaDo=''
        ''sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFdgqbWWmRPcf08grx/ADvz/5nvrxu5yc0QBN1/DiEPRAAAABHNzaDo=''
      ];
    };

    jellyfin = {
      extraGroups = [ "media" ];
    };
  };

  pb.mullvad = {
    enable = true;
    portBypasses = [ 443 22 ];
  };

  services.zfs.autoScrub.enable = true;
  services.sanoid = {
    enable = true;
    templates.videoBackup = {
      hourly = 48;
      daily = 7;
      weekly = 2;
      monthly = 1;
      autosnap = true;
      autoprune = true;
    };

    datasets = {
      "media/Anime".useTemplate = [ "videoBackup" ];
      "media/Movies".useTemplate = [ "videoBackup" ];
      "media/Shows".useTemplate = [ "videoBackup" ];
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      PubkeyAuthOptions = "touch-required";
    };
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."jellyfin.catouc.com" = {
      forceSSL = true;
      enableACME = true;

      locations."/".proxyPass = "http://127.0.0.1:8096";
    };

    virtualHosts."photos.catouc.com" = {
      forceSSL = true;
      enableACME = true;
      http2 = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:2342";
        proxyWebsockets = true;
      };
    };
  };

  services.photoprism = {
    enable = true;
    port = 2342;
    originalsPath = "/var/lib/private/photoprism/originals";
    address = "0.0.0.0";
    settings = {
      PHOTOPRISM_ADMIN_USER = "admin";
      # PHOTOPRISM_ADMIN_PASSWORD = lib.readFile /var/secrets/photoprism;
      PHOTOPRISM_DEFAULT_LOCALE = "en";
      PHOTOPRISM_DATABASE_DRIVER = "mysql";
      PHOTOPRISM_DATABASE_NAME = "photoprism";
      PHOTOPRISM_DATABASE_SERVER = "/run/mysqld/mysqld.sock";
      PHOTOPRISM_DATABASE_USER = "photoprism";
      PHOTOPRISM_SITE_URL = "https://photos.catouc.com";
      PHOTOPRISM_SITE_TITLE = "Photos";
    };
  };

  services.mysql = {
    enable = true;
    dataDir = "/data/mysql";
    package = pkgs.mariadb;
    ensureDatabases = [ "photoprism" ];
    ensureUsers = [ {
      name = "photoprism";
      ensurePermissions = {
        "photoprism.*" = "ALL PRIVILEGES";
      };
    } ];
  };

  fileSystems."/var/lib/private/photoprism" = {
    device = "/media/photoprism";
    options = [ "bind" ];
  };

  fileSystems."/var/lib/private/photoprism/originals" ={
    device = "/media/Photos";
    options = [ "bind" ];
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@philipp.boeschen.me";
    certs."jellyfin.catouc.com" = {
      dnsProvider = "cloudflare";
      environmentFile = /var/secrets/cloudflare;
      webroot = null;
    };
    certs."photos.catouc.com" = {
      dnsProvider = "cloudflare";
      environmentFile = /var/secrets/cloudflare;
      webroot = null;
    };
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
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
    nyaa-bulk
    vim
    tmux
    yt-dlp
  ];

  system.stateVersion = "23.11"; # Did you read the comment?
}

