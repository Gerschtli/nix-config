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
      # GRANT ALL PRIVILEGES ON *.* TO 'root'@'10.233.%.2' IDENTIFIED BY '<password>' WITH GRANT OPTION;
      mysql.enable = true;
    };
  };
}
