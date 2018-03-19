{ config, lib, pkgs, ... }:

with lib;

let
  inherit (builtins) listToAttrs;

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

    environment.etc = listToAttrs
      (map
        (file:
          let filePath = "${path}/${file}"; in
          nameValuePair
            filePath
            { source = ../../files + "/${filePath}"; }
        )
        ["index.html" "robots.txt"]
      );

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
