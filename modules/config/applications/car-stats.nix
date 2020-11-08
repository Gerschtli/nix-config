{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.applications.car-stats;

  containerAddress = "10.233.${toString cfg.containerID}.2";
in

{

  ###### interface

  options = {

    custom.applications.car-stats = {
      enable = mkEnableOption "car-stats";

      containerID = mkOption {
        type = types.int;
        description = "Container ID.";
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom = {
      services = {
        # Need to run:
        # CREATE USER 'car_stats'@'10.233.%.2' IDENTIFIED BY 'password';
        # GRANT ALL PRIVILEGES ON car_stats.* TO 'car_stats'@'10.233.%.2';
        mysql = {
          enable = true;
          backups = [ "car_stats" ];
        };

        nginx.enable = true;
      };

      system.firewall.openPortsForIps = [
        {
          ip = containerAddress;
          port = config.services.mysql.port;
        }
      ];
    };

    services.nginx.virtualHosts."auto.tobias-happ.de" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://${containerAddress}:80/";
    };

  };
}
