{ pkgs, ...}:
{
  home.packages = [
    pkgs.alacritty
  ];

  home.file."alacritty.yml" = {
    enable = true;
    source = ../configs/alacritty.yml;
    target = "./.config/alacritty/alacritty.yml";
  };
}
