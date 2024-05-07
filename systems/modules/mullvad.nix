{ ... }:
{
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
        tcp dport 8096 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
      }

      chain allowOutgoing {
        type route hook output priority -100; policy accept;
        tcp sport 8096 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
      }
    '';
  };
}
