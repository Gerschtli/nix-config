{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.applications.actual;
  actualCfg = config.services.actual;

  domain = "actual.tobias-happ.de";
in

{

  ###### interface

  options = {

    custom.applications.actual.enable = mkEnableOption "actual";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.services = {
      backup.services.actual = {
        description = "Actual";
        interval = "Tue *-*-* 04:30:00";

        directoryToBackup = actualCfg.settings.dataDir;
      };

      nginx.enable = true;
    };

    services = {
      actual = {
        enable = true;
        settings.port = 5006;
      };

      nginx.virtualHosts.${domain} = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://127.0.0.1:${toString actualCfg.settings.port}/";
      };
    };

  };

}
