{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom = {
    boot.mode = "raspberry";

    server.enable = true;
  };

  networking.hostName = "xenon";
}
