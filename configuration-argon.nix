{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom.desktop = {
    enable = true;
    laptop = true;
    wm = "i3";
  };

  networking.hostName = "argon";
}
