{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom = {
    applications = {
      gitea.enable = true;
      tobias-happ.enable = true;
    };

    server = {
      enable = true;
      rootLogin = true;
    };
  };

  networking.hostName = "krypton";
}
