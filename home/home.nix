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
      pkgs.discord
      pkgs.gh
      pkgs.go
      pkgs.jetbrains.goland
      pkgs.vscode
      pkgs.thunderbird
      pkgs.rustc
      pkgs.cargo
      pkgs.docker-compose
    ];
    
  };
    
  programs.home-manager.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.go.enable = true;
}
