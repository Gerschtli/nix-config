{ config, dirs, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.applications.tobias-happ;

  path = "nginx/tobias-happ.de";
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
      "${path}/index.html".source = dirs.files + "/tobias-happ.de/index.html";
      "${path}/robots.txt".source = dirs.files + "/tobias-happ.de/robots.txt";
    };

    services.nginx.virtualHosts = {
      "tobias-happ.de" = {
        root = "/etc/${path}";
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
