{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.applications.tobias-happ;

  path = "nginx/tobias-happ.de";
in

{

  ###### interface

  options = {

    custom.applications.tobias-happ.enable = mkEnableOption "tobias-happ.de";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.services.nginx.enable = true;

    # FIXME: use symlinkJoin instead of /etc files
    environment.etc = listToAttrs
      (map
        (file:
          nameValuePair
            "${path}/${file}"
            { source = ./. + "/${file}"; }
        )
        [ "index.html" "robots.txt" ]
      );

    services.nginx.virtualHosts = {
      "tobias-happ.de" = {
        default = true;
        root = "/etc/${path}";
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
