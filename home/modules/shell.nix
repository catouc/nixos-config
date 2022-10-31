{ ... }:
{
  home.shellAliases = {
    gs = "git status";
    gp = "git push";
    gpu = "git push -u origin $(git rev-parse --abbrev-ref HEAD)";
    kc = "kubectl";
    l = "ls -lisah";
  };
}
