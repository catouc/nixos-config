{ config, pkgs, git-email, common-pkgs, ... }:

{

  imports = [
    (import modules/shell.nix)
    (import modules/git.nix)
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

  programs.home-manager.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
