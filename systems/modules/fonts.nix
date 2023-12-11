{ pkgs, ... }:
{
  # Font config, nerdfonts can be big so maybe an
  # override would be useful for mobile systems
  # My main font configured for everything is
  # "DroidSansM Nerd Font Mono"
  fonts = {
    fontDir.enable = true;
    fontconfig.enable = true;
    enableDefaultPackages = true;
    packages = [
      pkgs.nerdfonts
    ];
  };
}
