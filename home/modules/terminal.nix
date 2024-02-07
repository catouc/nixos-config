{ pkgs, ...}:
{
  home.packages = [
    pkgs.alacritty
  ];

  home.file."alacritty.yml" = {
    enable = true;
    source = ../configs/alacritty.toml;
    target = "./.config/alacritty/alacritty.toml";
  };
}
