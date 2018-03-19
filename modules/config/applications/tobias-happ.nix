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

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.services.nginx.enable = true;

    environment.etc = {
      "nginx/tobias-happ.de/index.html".source = ../../files/tobias-happ.de/index.html;
      "nginx/tobias-happ.de/robots.txt".source = ../../files/tobias-happ.de/robots.txt;
    };

    services.nginx.virtualHosts = {
      "tobias-happ.de" = {
        root = "/etc/nginx/tobias-happ.de";
        default = true;
        enableACME = true;
        forceSSL = true;
        locations."/".tryFiles = "$uri /index.html";
      };

      "*.tobias-happ.de" = {
        extraConfig = "return 302 https://tobias-happ.de/;";
      };
    };

  };

}
