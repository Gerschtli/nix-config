{ config, lib, pkgs, ... } @ args:

let
  customLib = import ../../lib args;
in

customLib.containerApp rec {
  name = "car-stats";

  hostName = "auto.tobias-happ.de";

  containerPort = 80;

  extraConfig = cfg: {
    custom.services = {
      firewall.openPortsForIps = [
        {
          ip = cfg.containerAddress;
          port = config.services.mysql.port;
        }
      ];

      # Need to run:
      # CREATE USER 'car_stats'@'10.233.%.2' IDENTIFIED BY 'password';
      # GRANT ALL PRIVILEGES ON car_stats.* TO 'car_stats'@'10.233.%.2';
      mysql = {
        enable = true;
        backups = [ "car_stats" ];
      };
    };
  };
}
