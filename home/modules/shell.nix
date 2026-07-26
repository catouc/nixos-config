{ pkgs, lib, ... }:
{
  home = {
    shellAliases = {
      grep = "rg";
      kc = "kubectl";
      l = "ls -lisah";
    };

    packages = with pkgs; [
      stinkpot
    ];
  };

  programs.autojump.enable = true;

  programs.bash = {
    enable = true;
    initExtra = ''
      export EDITOR="vim"
      eval "$(${pkgs.stinkpot}/bin/stinkpot init)"
    '';
  };

  programs.starship = {
    enable = true;

    settings = {
      add_newline = false;
      format = "$username$hostname$directory$git_branch$character";

      username = {
        show_always = true;
        format = "[$user@]($style)";
        style_user = "bold red";
      };

      hostname = {
        ssh_only = false;
        format = "[$hostname]($style) ";
        style = "bold red";
      };

      directory = {
        format = "[$path](bold red) ";
      };

      character = {
        success_symbol = "[>](bold yellow)";
        error_symbol = "[>](bold red)";
      };

      git_branch = {
        format = "[$branch(:$remote_branch)](bold yellow)";
      };

      package = {
        disabled = true;
      };
    };
  };
}
