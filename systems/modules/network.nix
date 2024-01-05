{ networkManagerEnabled, hostName, ... }:
{
  networking.hostName = hostName;
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];
}
