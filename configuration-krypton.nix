{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/general.nix
    ./modules/server.nix
  ];

  boot.loader.grub = {
    device = "/dev/sda";
    enable = true;
    version = 2;
  };

  networking.hostName = "krypton";
}
