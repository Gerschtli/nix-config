{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.ip-watcher.client;

  user = "ip-watcher";
  filename = "${config.networking.hostName}.ip";
in

{

  ###### interface

  options = {

    custom.services.ip-watcher.client = {
      enable = mkEnableOption "ip-watcher client module";

      interval = mkOption {
        type = types.str;
        description = ''
          Systemd calendar expression when to update the ip address. See
          <citerefentry><refentrytitle>systemd.time</refentrytitle>
          <manvolnum>7</manvolnum></citerefentry>.
        '';
      };

      serverIp = mkOption {
        type = types.str;
        description = ''
          IP of server with ip-watcher service.
        '';
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.utils = {
      systemd.timers.ip-watcher = {
        inherit (cfg) interval;
        description = "IP watcher";

        serviceConfig = {
          serviceConfig = {
            Group = user;
            User = user;
          };
          script = ''
            ${pkgs.bind.dnsutils}/bin/dig @resolver1.opendns.com A myip.opendns.com +short -4 | \
              ${pkgs.openssh}/bin/ssh \
                -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
                -i ${config.lib.custom.path.secrets}/id_rsa.ip-watcher \
                ${user}@${cfg.serverIp} "cat > '${filename}'"
          '';
        };
      };

      systemUsers.${user} = {};
    };
  };

}
