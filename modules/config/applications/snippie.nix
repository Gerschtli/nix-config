{ config, dirs, lib, pkgs, ... } @ args:

let
  customLib = import dirs.lib args;
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
