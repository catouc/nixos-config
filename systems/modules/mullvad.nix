{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.pb.mullvad;
in
{
  options.pb.mullvad = {
    enable = mkEnableOption "Enable the mullvad service with fixes and passthroughs for firewalls";

    portBypasses = mkOption {
      type = types.listOf types.port;
      default = [];
      description = mDoc "A set of ports we want to bypass the wireguard tunnels, for server side stuff";
    };
  };

  config = mkIf cfg.enable {
    services.mullvad-vpn.enable = true;

    # based on https://discourse.nixos.org/t/connected-to-mullvadvpn-but-no-internet-connection/35803/12
    # to restore mullvad VPN DNS resolution
    networking.resolvconf.extraConfig = ''
      dynamic_order='tap[0-9]* tun[0-9]* vpn vpn[0-9]* wg* wg[0-9]* ppp[0-9]* ippp[0-9]*'
    '';

    networking.nftables.tables.vpnExcludeTraffic = {
      enable = true;
      family = "inet";
      content = ''
        chain allowIncoming {
          type filter hook input priority -100; policy accept;
          ${strings.concatMapStringsSep "\n"
            (port: "tcp dport ${port} ct mark set 0x00000f41 meta mark set 0x6d6f6c65;")
            (lists.forEach cfg.portBypasses (x: toString x))
          }
        }

        chain allowOutgoing {
          type route hook output priority -100; policy accept;
          ${lib.strings.concatMapStringsSep "\n"
            (port: "tcp sport ${port} ct mark set 0x00000f41 meta mark set 0x6d6f6c65;")
            (lists.forEach cfg.portBypasses (x: toString x))
          }
        }
      '';
    };
  };
}
