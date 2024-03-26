{ git-email, url-rewrites ? { }, ... }:
{
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
