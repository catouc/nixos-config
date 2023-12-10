{ networkManagerEnabled, hostName, ... }:
{
  networking.hostName = "changeling";
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];
}
