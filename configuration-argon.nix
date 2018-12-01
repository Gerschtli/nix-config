{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom.base.desktop = {
    enable = true;
    laptop = true;
  };

  networking.hostName = "argon";
}
