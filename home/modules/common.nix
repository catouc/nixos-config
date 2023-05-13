{ pkgs, ... }:

{
  home.packages = [
    pkgs.delta
    pkgs.file
    pkgs.gcc
    pkgs.git
    pkgs.go
    pkgs.gopls
    pkgs.google-chrome
    pkgs.htop
    pkgs.jq
    pkgs.ncspot
    pkgs.unzip
    pkgs.vim
    pkgs.wget
    pkgs.spotify
    pkgs.semver
    pkgs.tmux
    pkgs.xsv
    pkgs.zip
  ];

  programs.home-manager.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraConfig = ''
      syntax off
      set number
    '';
    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-lspconfig;
	type = "lua";
	config = ''
	  local lspconfig = require('lspconfig')
	  lspconfig.gopls.setup{}
	'';
      }
    ];
  };
}
