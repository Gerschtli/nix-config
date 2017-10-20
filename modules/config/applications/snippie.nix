{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.applications.snippie;

  hostName = "snippie.tobias-happ.de";
in

{

  ###### interface

  options = {

    custom.applications.snippie = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to install ${hostName}.
        '';
      };

      containerAddress = mkOption {
        type = types.str;
        default = "10.233.1.2";
        description = ''
          Container address.
        '';
      };

      containerPort = mkOption {
        type = types.str;
        default = "8080";
        description = ''
          Container port.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.services = {
      redis.enable = true;
      nginx.enable = true;
    };

    networking.firewall.extraCommands = ''
      iptables -I INPUT -p tcp -s ${cfg.containerAddress} --dport ${toString config.services.redis.port} -j ACCEPT
    '';

    services.nginx = {
      virtualHosts."${hostName}" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://${cfg.containerAddress}:${cfg.containerPort}/";
      };
    };

  };

}
