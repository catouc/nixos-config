{ pkgs, ... }: {
  imports = [
    ../modules/ytdl-sub.nix
    ../modules/security.nix

    ./hardware-configuration.nix
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;

  networking.hostName = "marut";
  networking.domain = "";
  networking.nftables.enable = true;
  networking.nftables.flushRuleset = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
  };

  users.users = {
    pb = {
      isNormalUser = true;
      extraGroups = [ "wheel" "jellyfin" ];
      openssh.authorizedKeys.keys = [
        ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEUrXTWtqfBvZCn/SPlN0nZmhPhwvOc4M8gPeKN1b2eZ''
        ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINY+KfRjOhVNBHU0so8CI3zoXFQAvYtgCxKsAmQYjfSE''
        ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPRVGs2ui3gP3O8TgQP6+UJIQZrwipZgcDltOdIXvT4Y''
        ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJwwqbgUcJyKz5y+rrfjfSMmNwbhQ6/bygrVcyCbNMWx pb@changeling''
        ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINOgT1Yh3UjIQvBzHOjnc4upo4sIRE1lZz+dB40P58Gj pb@penguin''
      ];
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
    enable = false;
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
    buildMachinesFiles = [ ];
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
