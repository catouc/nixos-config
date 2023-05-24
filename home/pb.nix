{ config, pkgs, ... }:

{
  imports = [
    (import modules/common.nix)
    (import modules/shell.nix)
    (import modules/editor.nix)
    (import modules/git.nix { git-email = "catouc@philipp.boeschen.me"; })
  ];

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
