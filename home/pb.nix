{ config, pkgs, common-pkgs, ... }:

{
  imports = [
    (import modules/common.nix)
    (import modules/shell.nix)
    (import modules/git.nix { git-email = "catouc@philipp.boeschen.me"; })
  ];

  home = {
    username = "pb";
    homeDirectory = "/home/pb";
    stateVersion = "22.05";
    packages = [
      pkgs.cargo
      pkgs.discord
      pkgs.docker-compose
      pkgs.gcc
      pkgs.gh
      pkgs.vscode
      pkgs.rustc
      pkgs.thunderbird
    ] ++ common-pkgs;
  };
}
