{ ... }:
{
  home = {
    shellAliases = {
      gs = "git status";
      gp = "git push";
      gpu = "git push -u origin $(git rev-parse --abbrev-ref HEAD)";
      gpum = "git push -u origin $(git rev-parse --abbrev-ref HEAD) -o merge_request.create";
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
