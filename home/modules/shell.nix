{ ... }:
{
  home = {
    shellAliases = {
      gs = "git status";
      gp = "git push";
      gpu = "git push -u origin $(git rev-parse --abbrev-ref HEAD)";
      kc = "kubectl";
      l = "ls -lisah";
    };
  };

  programs.fzf.enable = true;
  programs.autojump.enable = true;

  programs.bash = {
    enable = true;
    initExtra = ''
      export EDITOR="vim"
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
        style_user = "bold green";
      };

      hostname = {
        ssh_only = false;
        format = "[$hostname]($style) ";
        style = "bold green";
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
