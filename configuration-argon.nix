{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom.desktop = {
    enable = true;
    laptop = true;
  };

  networking.hostName = "argon";
}
