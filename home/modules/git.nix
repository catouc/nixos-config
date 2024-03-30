{ git-email, url-rewrites ? { }, ... }:
{
  home.shellAliases = {
    gs = "git status";
    gp = "git push";
    gpu = "git push -u origin $(git rev-parse --abbrev-ref HEAD)";
    gpum = "git push -u origin $(git rev-parse --abbrev-ref HEAD) -o merge_request.create";
  };
  programs.git = {
    enable = true;
    userName = "Philipp Böschen";
    userEmail = "${git-email}";

    aliases = {
      tree = "log --graph --decorate --oneline --abbrev-commit";
    };

    extraConfig = {
      core = {
        pager = "delta";
      };

      interactive = {
        diffFilter = "delta --color-only";
      };

      delta = {
        navigate = true;
        light = false;
      };

      merge = {
        conflictstyle = "diff3";
      };

      diff = {
        colorMoved = "default";
      };

      init = {
        defaultBranch = "main";
      };

      pull = {
        rebase = true;
      };

      push = {
        autoSetupRemote = true;
      };

      url = url-rewrites;
    };
  };
}
