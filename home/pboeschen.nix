{ config, pkgs, ... }:
let
  url-rewrites = {
    "ssh://git@gitlab.booking.com/" = {
      insteadOf = "https://gitlab.booking.com/";
    };
  };
in
{

  imports = [
    (import modules/common.nix)
    (import modules/shell.nix)
    (import modules/git.nix {
      git-email = "philipp.boeschen@booking.com";
      inherit url-rewrites;
    })
  ];

  home = {
    username = "pboeschen";
    homeDirectory = "/home/pboeschen";
    stateVersion = "22.05";
    packages = [
      pkgs.gcc
      pkgs.globalprotect-openconnect
      pkgs.k9s
      pkgs.kubectl
      pkgs.kustomize
      pkgs.slack
      pkgs.zoom-us
    ];
  };
}
