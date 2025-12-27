{ pkgs, ... }:
{
  nix = {
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 15d";
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    package = pkgs.lixPackageSets.stable.lix;
  };
}
