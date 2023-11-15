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

  xdg.desktopEntries = {
    alacritty = {
      name = "Alacritty";
      genericName = "Terminal";
      icon = "Alacritty";
      type = "Application";
      exec = "nixGL alacritty";
      terminal = false;
      categories = [ "System" "TerminalEmulator" ];

      actions.New = {
        name = "New Terminal";
        exec = "nixGL alacritty";
      };
    };
  };
}

