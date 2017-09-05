{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./modules/general.nix
    ./modules/pass.nix

    ./services/pulseaudio.nix

    ./modules/xserver.nix
  ];

  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub.device = "/dev/sda";
    systemd-boot.enable = true;
  };

  services.xserver.synaptics = {
    enable = true;
    twoFingerScroll = true;
    buttonsMap = [ 1 3 2 ];
  };

  networking.networkmanager.enable = true;

  networking.hostName = "argon";
}
