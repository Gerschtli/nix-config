{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./modules/general.nix
    ./modules/pass.nix

    ./services/pulseaudio.nix

    ./modules/xserver-laptop.nix
  ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub.device = "/dev/sda";
    systemd-boot = {
      enable = true;
      editor = false;
    };
  };

  networking.hostName = "argon";
}
