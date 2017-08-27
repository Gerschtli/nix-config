{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/general.nix
    ./modules/desktop.nix
  ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub.device = "/dev/sda2";
    systemd-boot.enable = true;
  };

  networking.hostName = "tower";
}
