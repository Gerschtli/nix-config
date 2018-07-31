{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.applications.golden-river-jazztett;

  customLib = import ../../lib args;

  static-page = customLib.staticPage "httpd/golden-river-jazztett.de";
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

    custom.services = {
      httpd = {
        enable = true;
        virtualHosts = [
          {
            hostName = "goldenriverjazztett.de";
            serverAliases = [ "www.goldenriverjazztett.de" ];
            documentRoot = static-page.root;
          }
        ];
      };
    };

    environment.etc = static-page.environment.etc;
  };

}
