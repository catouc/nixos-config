{ pkgs, ... }:
{
  home.packages = with pkgs; [
    delta
    dig
    file
    git
    htop
    jq
    ripgrep
    semver
    tmux
    unzip
    zip
  ];

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
