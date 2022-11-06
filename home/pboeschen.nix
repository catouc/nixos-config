{ config, pkgs, git-email, common-pkgs, ... }:

{

  imports = [
    (import modules/shell.nix)
    (import modules/git.nix)
  ];

  home = {
    username = "pboeschen";
    homeDirectory = "/home/pboeschen";
    stateVersion = "22.05";
    packages = with pkgs; [
      pkgs.gcc
      pkgs.globalprotect-openconnect
      pkgs.k9s
      pkgs.kubectl
      pkgs.kustomize
      pkgs.slack
      pkgs.zoom-us
    ] ++ common-pkgs;
  };

  programs.home-manager.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
