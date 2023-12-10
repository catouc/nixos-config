{ ... }:
{
  users.users.pb = {
    isNormalUser = true;
    description = "Phil (Prv)";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };
}
