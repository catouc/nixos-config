{ ... }:
{
  users.users.pb = {
    isNormalUser = true;
    description = "Phil (Prv)";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    openssh.authorizedKeys.keys = [
      ''sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILbWTzMhSpruetqZrxqKuGbZSdjPBtT+utpLScb4y3obAAAABHNzaDo=''
      ''sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIOlJaLeMqxg7P+2lBzSjEbSf6tthaHiHD8IrOlTkFaNQAAAABHNzaDo=''
      ''sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFdgqbWWmRPcf08grx/ADvz/5nvrxu5yc0QBN1/DiEPRAAAABHNzaDo=''

    ];
  };
}
