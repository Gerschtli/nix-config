{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.applications.tobias-happ;
in

{

  ###### interface

  options = {

    custom.applications.tobias-happ = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to install tobias-happ.de.
        '';
      };

      root = mkOption {
        type = types.str;
        default = "/var/www/tobias-happ.de/";
        description = ''
          Default root folder.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.services.nginx.enable = true;

    services.nginx.virtualHosts = {
      "tobias-happ.de" = {
        enableACME = true;
        forceSSL = true;
        root = "${cfg.root}";
      };

      "*.tobias-happ.de" = {
        globalRedirect = "tobias-happ.de";
      };
    };

  };

}
