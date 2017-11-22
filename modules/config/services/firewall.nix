{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.firewall;
in

{

  ###### interface

  options = {

    custom.services.firewall = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable firewall.
        '';
      };

      openPortsForIps = mkOption {
        type = types.listOf (
          types.submodule {
            options = {

              ip = mkOption {
                type = types.str;
                description = ''
                  IP to open port for.
                '';
              };

              port = mkOption {
                type = types.int;
                description = ''
                  Port to open.
                '';
              };

              protocol = mkOption {
                type = types.enum [ "tcp" "udp" ];
                default = "tcp";
                description = ''
                  Protocol.
                '';
              };

            };
          }
        );
        default = [];
        description = ''
          Open ports for specific IPs.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    networking.firewall = {
      enable = true;
      allowPing = true;

      extraCommands = foldl (acc: option: ''
        ${acc}
        iptables -I INPUT -p ${option.protocol} -s ${option.ip} --dport ${toString option.port} -j ACCEPT
      '') "" cfg.openPortsForIps;
    };

    services.fail2ban.enable = true;

  };

}
