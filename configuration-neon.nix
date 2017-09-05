{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./modules/general.nix
    ./modules/pass.nix

    ./services/firewall.nix
    ./services/ssh.nix

    ./applications/golden-river-jazztett.nix
    ./applications/auto-golden-river-jazztett.nix
    ./applications/teamspeak.nix
  ];

  boot.loader.grub = {
    device = "/dev/sda";
    enable = true;
    version = 2;
  };

  networking.hostName = "neon";
}
