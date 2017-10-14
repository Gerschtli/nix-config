{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom = {
    applications = {
      snippie.enable = true;

      tobias-happ.enable = true;
    };

    server = {
      enable = true;
      rootLogin = true;
    };
  };

  networking.hostName = "krypton";
}
