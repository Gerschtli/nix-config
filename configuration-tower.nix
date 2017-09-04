{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./modules/general.nix

    ./services/cups.nix
    ./services/pulseaudio.nix

    ./modules/devHosts.nix
    ./modules/xserver.nix
  ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub.device = "/dev/sda2";
    systemd-boot.enable = true;
  };

  environment.systemPackages = with pkgs; [
    ntfs3g
  ];

  networking.hostName = "tower";
}
