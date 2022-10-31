{ git-email, ... }:
{
  programs.git = {
    enable = true;
    userName = "Philipp Böschen";
    userEmail = "${git-email}";

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
