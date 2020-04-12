{ config, pkgs, ... }:

{
  imports = [ ./modules ];


  custom = {
    base = {
      desktop = {
        enable = true;
        laptop = true;
      };

      general.hostName = "argon";
    };

    ids.enable = true;

    programs.arduino.enable = true;
  };
}
