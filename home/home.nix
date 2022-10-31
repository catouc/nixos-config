{ config, pkgs, user ... }:

{
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
    
    shellAliases = {
      gs = "git status";
      gp = "git push";
      gpu = "git push -u origin $(git rev-parse --abbrev-ref HEAD)";
      kc = "kubectl";
      l = "ls -lisah";
    };
    
    sessionVariables = {
      EDITOR = "vim";
    };
  };
    
  programs.home-manager.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.autojump.enable = true;
  programs.go.enable = true;
  programs.fzf.enable = true;
    
  programs.bash = {
    enable = true;
    initExtra = ''
      . "/$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    '';
  };

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

  programs.starship = {
   enable = true;
   
   settings = {
     add_newline = false;

     format = "$username$directory$git_branch$character";
       
     username = {
       show_always = true;
       format = "[$user]($style) ";
       style_user = "bold green";
     };

     directory = {
       format = "[$path](bold green) ";
     };

     character = {
       success_symbol = "[>](bold green)";
       error_symbol = "[>](bold red)";
     };

     git_branch = {
       format = "[$branch(:$remote_branch)](bold purple)";
     };

     package = {
       disabled = true;
     };
   };
  };
}
