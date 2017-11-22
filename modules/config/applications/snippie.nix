{ config, lib, pkgs, ... } @ args:

let
  customLib = import ../../lib args;
in

customLib.containerApp rec {
  name = "snippie";

  hostName = "${name}.tobias-happ.de";

  extraConfig = cfg: {
    custom.services.redis.enable = true;

    networking.firewall.extraCommands = ''
      iptables -I INPUT -p tcp -s ${cfg.containerAddress} --dport ${toString config.services.redis.port} -j ACCEPT
    '';
  };
}
