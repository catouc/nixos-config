{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    
    
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "marut";
  networking.domain = "";
  services.openssh.enable = true;
  programs.ssh.startAgent = true;
  environment.systemPackages = with pkgs; [
    git
    vim
  ];
  users.users.root.openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEUrXTWtqfBvZCn/SPlN0nZmhPhwvOc4M8gPeKN1b2eZ'' ];
  users.users.pb = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEUrXTWtqfBvZCn/SPlN0nZmhPhwvOc4M8gPeKN1b2eZ'' ];
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  system.stateVersion = "23.05";
}
