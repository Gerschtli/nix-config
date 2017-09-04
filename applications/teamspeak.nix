{ config, pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [
      10011
      30033
      41144
    ];

    allowedUDPPorts = [
      9987
    ];
  };

  nixpkgs.config.allowUnfree = true;

  services.teamspeak3.enable = true;
}
