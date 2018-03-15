{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom = {
    applications.tobias-happ.enable = true;

    server = {
      enable = true;
      rootLogin = true;
    };
  };

  networking.hostName = "krypton";
}
