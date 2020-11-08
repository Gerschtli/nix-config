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

    environment.etc = builtins.listToAttrs
      (map
        (file:
          let filePath = "${path}/${file}"; in
          lib.nameValuePair
            filePath
            { source = config.lib.custom.path.files + "/${filePath}"; }
        )
        ["index.html" "robots.txt" "setup.sh" "setup.txt"]
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
