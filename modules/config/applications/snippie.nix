{ config, lib, pkgs, ... } @ args:

let
  customLib = import ../../lib args;
in

customLib.containerApp rec {
  name = "snippie";

  hostName = "${name}.tobias-happ.de";

  extraConfig = cfg: {
    custom.services = {
      firewall.openPortsForIps = [
        {
          ip = cfg.containerAddress;
          port = config.services.redis.port;
        }
      ];

      redis.enable = true;
    };
  };
}
