# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix

      ../modules/mullvad.nix
      ../modules/nix.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;
  boot.loader.grub.device = "nodev";

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "media" ];

  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = "32768"; # 4 times the default 8192
  };

  networking.hostName = "gargoyle";
  networking.hostId = "7789dc7b";
  users.groups = {
    "media" = {};
  };

  networking = {
    interfaces = {
      enp4s0.ipv4.addresses = [{
        address = "192.168.1.10";
        prefixLength = 24;
      }];
    };
    defaultGateway = {
      address = "192.168.1.1";
      interface = "enp4s0";
    };
  };
  networking.nftables.enable = true;
  networking.nftables.flushRuleset = true;
  networking.firewall = {
    enable = true;

    trustedInterfaces = [ "tailscale0" ];
    allowedTCPPorts = [ 22 80 443 ];
    allowedUDPPorts = [ config.services.tailscale.port 53 ];
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

    kavita = {
      extraGroups = [ "media" ];
    };

    feed-to-epub = {
      extraGroups = [ "media" ];
    };
  };

  # This is broken until https://github.com/NixOS/nixpkgs/issues/385996 is fixed.
  pb.mullvad = {
    enable = true;
    portBypasses = [ 443 22 ];
    localHostBypasses = [
      {
        ipv4="192.168.1.0/24"; 
        ports = [ 8443 443 22 ];
      }
    ];
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
      "media/Music".useTemplate = [ "videoBackup" ];
      "media/Shows".useTemplate = [ "videoBackup" ];
      "media/ebooks".useTemplate = [ "videoBackup" ];
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

  services.firefly-iii = {
    enable = true;
    enableNginx = true;
    virtualHost = "accounting.boeschen.me";
    settings = {
      APP_KEY_FILE = "/var/secrets/firefly-iii-app-key.txt";
    };
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  feed-to-epub = {
    enable = true;
    group = "media";
    settings = {
      feeds = {
        "Dan Luu" = {
          url = "https://danluu.com/atom.xml";
          download_dir = "/media/ebooks/Blogs/danluu";
        };
        "Julia Evans" = {
          url = "https://jvns.ca/atom.xml";
          download_dir = "/media/ebooks/Blogs/julia_evans";
        };
        "Rachelbythebay" = {
          url = "https://rachelbythebay.com/w/atom.xml";
          download_dir = "/media/ebooks/Blogs/rachelbythebay";
        };
        "Ed Zitron" = {
          url = "https://www.wheresyoured.at/rss";
          download_dir = "/media/ebooks/Blogs/ed_zitron";
        };
      };
    };
  };

  services.kavita = {
    enable = true;
    dataDir = "/media/ebooks";
    tokenKeyFile = "/var/secrets/kavita";

    settings = {
      options = {
        IpAddresses = "127.0.0.1";
      };
    };
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

    virtualHosts."ebooks.boeschen.me" = {
      forceSSL = true;
      enableACME = true;

      locations."/".proxyPass = "http://127.0.0.1:5000";
    };

    virtualHosts."photos.catouc.com" = {
      forceSSL = true;
      enableACME = true;
      http2 = true;
      locations."/" = {
        proxyPass = "http://[::1]:${toString config.services.immich.port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
        extraConfig = ''
          client_max_body_size 50000M;
          proxy_read_timeout   600s;
          proxy_send_timeout   600s;
          send_timeout         600s;
        '';
      };
    };

    virtualHosts."accounting.boeschen.me" = {
      forceSSL = true;
      enableACME = true;
    };

    virtualHosts."homeassistant.boeschen.me" = {
      forceSSL = true;
      enableACME = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8123";
        proxyWebsockets = true;
      };
    };
  };

  services.immich = {
    enable = true;
    mediaLocation = "/media/Photos";
    group = "media";
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
    certs."accounting.boeschen.me" = {
      dnsProvider = "cloudflare";
      environmentFile = /var/secrets/cloudflare;
      webroot = null;
    };
    certs."ebooks.boeschen.me" = {
      dnsProvider = "cloudflare";
      environmentFile = /var/secrets/cloudflare;
      webroot = null;
    };
    certs."homeassistant.boeschen.me" = {
      dnsProvider = "cloudflare";
      environmentFile = /var/secrets/cloudflare;
      webroot = null;
    };
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };

  services.dnsmasq = {
    enable = true;
    settings = {
      port = 0; # disable DNS serving?
      dhcp-authoritative = true;
      dhcp-range = [ "192.168.178.50,192.168.178.150,5m" "::f,::ff,constructor:enp4s0" ] ;
      dhcp-option = [ "3,192.168.178.1" "6,192.168.178.1" ];
    };
  };

  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = [ "0.0.0.0" ];
        access-control = [ "192.168.178.0/24 allow" "127.0.0.1/32 allow" ];
        # Based on recommended settings in
        # https://docs.pi-hole.net/guides/dns/unbound/#configure-unbound
        harden-glue = true;
        harden-dnssec-stripped = true;
        use-caps-for-id = false;
        prefetch = true;
        edns-buffer-size = 1232;
        hide-identity = true;
        hide-version = true;
      };
      forward-zone = [
        # Example config with quad9
        {
          name = ".";
          forward-addr = [
            "9.9.9.9#dns.quad9.net"
            "149.112.112.112#dns.quad9.net"
          ];
          forward-tls-upstream = true;
        }
      ];
    };
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      volumes = [ "/var/home-assistant:/config" ];
      environment.TZ = "Europe/Amsterdam";
      # Note: The image will not be updated on rebuilds, unless the version label changes
      image = "ghcr.io/home-assistant/home-assistant:2025.8";
      ports = ["8888:8123"];
      extraOptions = [ 
        # Use the host network namespace for all sockets
        "--cap-add=CAP_NET_RAW,CAP_NET_BIND_SERVICE"
        # Pass devices into the container, so Home Assistant can discover and make use of them
        # "--device=/dev/ttyACM0:/dev/ttyACM0"
       "--network=host"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    git
    htop
    vim
    tmux
    mytube
    yt-dlp
    slskd
    ripgrep
    rtorrent
    feed-to-epub
  ];

  system.stateVersion = "23.11"; # Did you read the comment?
}

