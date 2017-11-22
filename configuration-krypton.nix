{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom = {
    applications = {
      snippie = {
        enable = true;
        containerID = 1;
      };

      spring-rest-api = {
        enable = true;
        containerID = 2;
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
