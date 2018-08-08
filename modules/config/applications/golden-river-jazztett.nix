{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.applications.golden-river-jazztett;

  customLib = import ../../lib args;

  static-page = customLib.staticPage "nginx/golden-river-jazztett.de";
in

{

  ###### interface

  options = {

    custom.applications.golden-river-jazztett = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to install goldenriverjazztett.de.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.services.nginx.enable = true;

    environment.etc = static-page.environment.etc;

    services.nginx.virtualHosts = {
      "goldenriverjazztett.de" = {
        inherit (static-page) root;
        default = true;
        enableACME = true;
        forceSSL = true;
        locations."/".tryFiles = "$uri /index.html";
      };

      "*.goldenriverjazztett.de" = {
        extraConfig = "return 302 https://goldenriverjazztett.de/;";
      };
    };

  };

}
