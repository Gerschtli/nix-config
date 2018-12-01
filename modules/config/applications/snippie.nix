{ config, lib, pkgs, ... } @ args:

let
  customLib = import ../../lib args;
in

customLib.containerApp rec {
  name = "snippie";

  hostName = "${name}.tobias-happ.de";

  extraConfig = cfg: {
    custom = {
      services.redis.enable = true;

      system.firewall.openPortsForIps = [
        {
          ip = cfg.containerAddress;
          port = config.services.redis.port;
        }
      ];
    };
  };
}
