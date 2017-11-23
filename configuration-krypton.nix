{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom = {
    applications = {
      plc-web-java = {
        enable = true;
        containerID = 3;
      };

      snippie = {
        enable = true;
        containerID = 1;
      };

      tobias-happ.enable = true;
    };

    server = {
      enable = true;
      rootLogin = true;
    };
  };

  networking.hostName = "krypton";
}
