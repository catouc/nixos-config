{ pkgs, ... }: {
  imports = [
    ../modules/nix.nix
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
    logRefusedConnections = false;
    allowedTCPPorts = [ 22 80 443 ];
  };

  users.users = {
    pb = {
      isNormalUser = true;
      extraGroups = [ "wheel" "jellyfin" ];
      openssh.authorizedKeys.keys = [
        ''sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILbWTzMhSpruetqZrxqKuGbZSdjPBtT+utpLScb4y3obAAAABHNzaDo=''
        ''sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIOlJaLeMqxg7P+2lBzSjEbSf6tthaHiHD8IrOlTkFaNQAAAABHNzaDo=''
        ''sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFdgqbWWmRPcf08grx/ADvz/5nvrxu5yc0QBN1/DiEPRAAAABHNzaDo=''
      ];
    };

    mediawiki = {
      extraGroups = [
        "keys"
      ];
    };
  };

  virtualisation.docker.enable = true;

  services.fail2ban.enable = true;

  services.mediawiki = {
    enable = true;
    name = "Panapa";
    webserver = "nginx";
    # There is only a default if you configure something for the apache server. I don't care
    # for it so this is necessary to set manually.
    passwordSender = "root@localhost";
    passwordFile = "/run/keys/mediaWikiInitialPassword";
    nginx.hostName = "panapa.catouc.com";
    extraConfig = ''
      # Disable reading by anonymous users
      $wgGroupPermissions['*']['read'] = false;

      # Disable anonymous editing
      $wgGroupPermissions['*']['edit'] = false;

      # Prevent new user registrations except by sysops
      $wgGroupPermissions['*']['createaccount'] = false;
    '';

    extensions = {
      Cargo = pkgs.fetchzip {
        url = "https://github.com/wikimedia/mediawiki-extensions-Cargo/archive/3.5.1.zip";
        hash = "sha256-mEzeCnZyFK6ig9JZD2ZsGN2slfvhBttohxYDDHKB5zU=";
      };

      "PageForms" = pkgs.fetchzip {
        url = "https://github.com/wikimedia/mediawiki-extensions-PageForms/archive/6.0.1.zip";
        hash = "sha256-L+qWC7LjABbzs+YMnnNVhKEGgKlH+AWTci2KwWkEEPk=";
      };
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

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."panapa.catouc.com" = {
      forceSSL = true;
      enableACME = true;
    };

    virtualHosts."splitwise.boeschen.me" = {
      forceSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        extraConfig = "proxy_ssl_server_name on;";
      };
    };

    virtualHosts."perlwith.catouc.com" = {
      forceSSL = true;
      enableACME = true;

      locations."/" = {
        proxyPass = "http://127.0.0.1:3030";
        extraConfig = "proxy_ssl_server_name on;";
        proxyWebsockets = true;
      };
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "spliit" ];
    ensureUsers = [
      {
        name = "spliit";
        ensureDBOwnership = true;
      }
    ];
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers.rustpad = {
      # Note: The image will not be updated on rebuilds, unless the version label changes
      image = "docker.io/ekzhang/rustpad:latest";
      ports = ["3030:3030"];
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@philipp.boeschen.me";
  };

  environment.systemPackages = with pkgs; [
    git
    htop
    vim
    tmux
  ];

  system.stateVersion = "23.05";
}
