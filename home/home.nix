{ config, pkgs, user, git-email, ... }:

{

  imports = [
    (import modules/shell.nix)
    (import modules/git.nix)
  ];
  home = {
    username = "${user}";
    homeDirectory = "/home/${user}";
    stateVersion = "22.05";
    packages = with pkgs; [
      pkgs.cargo
      pkgs.discord
      pkgs.docker-compose
      pkgs.gh
      pkgs.go
      pkgs.google-chrome
      pkgs.jetbrains.goland
      pkgs.vscode
      pkgs.rustc
      pkgs.spotify
      pkgs.thunderbird
    ];
    
  };
    
  programs.home-manager.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
