{ config, pkgs, user, ... }:

{

  imports = [
    (import modules/shell.nix)
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
    
  programs.git = {
    enable = true;
    userName = "Philipp Böschen";
    userEmail = "catouc@philipp.boeschen.me";

    aliases = {
      tree = "log --graph --decorate --oneline --abbrev-commit";
    };

    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      pull = {
        rebase = true;
      };
    };
  };

}
