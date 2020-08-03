{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

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
