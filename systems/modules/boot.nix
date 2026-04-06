{ ... }:
{
  # TODO: Clean up unused targets to speed up boot for fun
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # This thing is exceptionally slow at boot
  nix.gc.randomizedDelaySec = "2m";

  # Oneshot service that only waits for the network to be available
  # all of my installs come from local disk so this is unnecessarily
  # delaying my boot
  systemd.services.NetworkManager-wait-online.enable = false;
}
