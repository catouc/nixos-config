{ pkgs, config, ... }:
{
  home = {
    username = "pb";
    homeDirectory = "/home/pb";
    stateVersion = "22.05";
    packages = [
      pkgs.cargo
      pkgs.gcc
      pkgs.rustc
      pkgs.thunderbird
    ];
  };
}
