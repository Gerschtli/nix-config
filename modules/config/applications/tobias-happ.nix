{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.applications.tobias-happ;

  customLib = import ../../lib args;

  static-page = customLib.staticPage "nginx/tobias-happ.de";
in

{

  ###### interface

  options = {

    custom.applications.tobias-happ.enable = mkEnableOption "tobias-happ.de";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.services.nginx.enable = true;

    environment.etc = static-page.environment.etc;

    services.nginx.virtualHosts = {
      "tobias-happ.de" = {
        inherit (static-page) root;
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
