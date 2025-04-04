{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # xsv they fucking removed it?! It's the best thing ever :x`
    bluez
    delta
    dig
    file
    firefox
    git
    htop
    jq
    obsidian
    powertop
    ripgrep
    semver
    tmux
    unzip
    vim
    wget
    xclip
    zip
  ];

  programs.home-manager.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
