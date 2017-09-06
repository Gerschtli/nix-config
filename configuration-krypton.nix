{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./modules/general.nix

    ./services/firewall.nix
    ./services/ssh.nix
  ];

  boot.loader.grub = {
    device = "/dev/sda";
    enable = true;
    version = 2;
  };



#  imports = [
#    ./modules/interface.nix
#  ];
#
#  custom.server.enable = true;

  networking.hostName = "krypton";
}
