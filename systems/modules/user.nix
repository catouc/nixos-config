{ ... }:
{
  users.users.pb = {
    isNormalUser = true;
    description = "Phil (Prv)";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    openssh.authorizedKeys.keys = [
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJwwqbgUcJyKz5y+rrfjfSMmNwbhQ6/bygrVcyCbNMWx pb@changeling''
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINOgT1Yh3UjIQvBzHOjnc4upo4sIRE1lZz+dB40P58Gj pb@penguin''
    ];
  };
}
