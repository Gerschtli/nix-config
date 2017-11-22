{ config, lib, pkgs, ... }:

import ../../lib/container-app.nix rec {
  inherit config lib pkgs;

  name = "snippie";

  hostName = "${name}.tobias-happ.de";

  extraConfig = cfg: {
    custom.services.redis.enable = true;

    networking.firewall.extraCommands = ''
      iptables -I INPUT -p tcp -s ${cfg.containerAddress} --dport ${toString config.services.redis.port} -j ACCEPT
    '';
  };
}
