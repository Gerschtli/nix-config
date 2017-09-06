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
    ./services/teamspeak.nix
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
#  custom.server = {
#    enable = true;
#    programs = {
#      autoGoldenRiverJazztett = true;
#      goldenRiverJazztett = true;
#      teamspeak = true;
#    };
#  };

  networking.hostName = "neon";
}
