{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./modules/general.nix

    ./services/firewall.nix
    ./services/ssh.nix

    ./applications/goldenRiverJazztett.nix
    ./applications/autoGoldenRiverJazztett.nix
    ./applications/teamspeak.nix
  ];

  boot.loader.grub = {
    device = "/dev/sda";
    enable = true;
    version = 2;
  };

  networking.hostName = "krypton";
}
