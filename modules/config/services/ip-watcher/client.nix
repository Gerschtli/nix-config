{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.ip-watcher.client;
in

{

  ###### interface

  options = {

    custom.services.ip-watcher.client = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable the ip-watcher client module.
        '';
      };

      group = mkOption {
        type = types.str;
        default = cfg.user;
        description = ''
          Group name.
        '';
      };

      user = mkOption {
        type = types.str;
        default = "ip-watcher";
        description = ''
          User name.
        '';
      };

      filename = mkOption {
        type = types.str;
        default = "${config.networking.hostName}.ip";
        description = ''
          File name where to save the ip address.
        '';
      };

      interval = mkOption {
        type = types.str;
        description = ''
          Systemd calendar expression when to update the ip address. See
          <citerefentry><refentrytitle>systemd.time</refentrytitle>
          <manvolnum>7</manvolnum></citerefentry>.
        '';
      };

      ssh = {

        ip = mkOption {
          type = types.str;
          description = ''
            IP of server with ip-watcher service.
          '';
        };

        user = mkOption {
          type = types.str;
          default = config.custom.services.ip-watcher.server.user;
          description = ''
            SSH user name.
          '';
        };

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
            Group = cfg.group;
            User = cfg.user;
          };
          script = ''
            ${pkgs.bind.dnsutils}/bin/dig @resolver1.opendns.com A myip.opendns.com +short -4 | \
              ${pkgs.openssh}/bin/ssh \
                -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
                -i ${toString ../../../secrets/id_rsa.ip-watcher} \
                ${cfg.ssh.user}@${cfg.ssh.ip} "cat > '${cfg.filename}'"
          '';
        };
      };

      systemUsers.${cfg.user} = { inherit (cfg) group; };
    };

  };

}
