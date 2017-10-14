{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom = {
    desktop = {
      enable = true;
      laptop = true;
    };

    dev.enable = true;
  };

  networking.hostName = "argon";
}
