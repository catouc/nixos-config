# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

      ../modules/mullvad.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;
  boot.loader.grub.device = "nodev";

  networking.hostName = "gargoyle";
  users.groups = {
    "media" = {};
  };

  networking.nftables.enable = true;
  networking.nftables.flushRuleset = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
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
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@philipp.boeschen.me";
    certs."jellyfin.catouc.com" = {
      dnsProvider = "cloudflare";
      environmentFile = /run/keys/cloudflare;
      webroot = null;
    };
  };

  services.tailscale.enable = true;

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

    system.stateVersion = "23.11"; # Did you read the comment?
}

