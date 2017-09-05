{ config, pkgs, ... }:

{
  imports = [
    ./xserver.nix
  ];

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
    upower
    xorg.xbacklight
  ];

  services.xserver.synaptics = {
    enable = true;
    twoFingerScroll = true;
    buttonsMap = [ 1 3 2 ];
  };

  networking.networkmanager.enable = true;
}
