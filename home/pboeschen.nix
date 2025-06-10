{ pkgs, nixgl, ... }:
let
  logbook = pkgs.writeShellScriptBin "lb" ''
    #! /usr/bin/env bash
    set -euo pipefail
    vim ~/Logbook/$(date --rfc-3339=date)
  '';
in
{
  imports = [
    ./modules/i3.nix
    ./modules/terminal.nix
    ./modules/git.nix
  ];

  nixGL.packages = nixgl.packages;
  nixGL.defaultWrapper = "mesa";
  nixGL.installScripts = ["mesa"];

  pb.home.i3 = {
    enable = true;
    configFile = ./configs/work-i3;
    polybarName = "changeling";
  };

  pb.home.terminal = {
    enable = true;
  };

  pb.home.git = {
    enable = true;
    email = "philipp.boeschen@booking.com";
    urlRewrites = [
      {
        from = "https://gitlab.booking.com";
        to = "ssh://git@gitlab.booking.com";
      }
      {
        from = "https://gitlab.com";
        to = "ssh://git@gitlab.com";
      }
    ];
  };

  home.file."wireplumber.bluetooth.lua.d" = {
    enable = true;
    source = ./configs/wireplumber-51-bluez-config.lua;
    target = "./.config/wireplumber/bluetooth.lua.d/51-bluez-config.lua";
  };

  targets.genericLinux.enable=true;

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };

  systemd.user.services.ssh-agent = {
    Install.WantedBy = [ "default.target" ];

    Unit = {
      Description = "SSH authentication agent";
      Documentation = "man:ssh-agent(1)";
    };

    Service = {
      ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a %t/ssh-agent";
    };
  };
  programs.bash = {
    enable = true;
    initExtra = ''
      if [ -z "$SSH_AUTH_SOCK" ]; then
        export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent
      fi
    '';
  };

  home = {
    username = "pboeschen";
    homeDirectory = "/home/pboeschen";
    stateVersion = "22.05";
    packages = (with pkgs; [
      autorandr
      gitlab-notifications
      k9s
      kubectl
      nerd-fonts.droid-sans-mono
      okta-aws-cli
      vault
      pwvucontrol
    ]) ++ [
      logbook
    ];
  };
}
