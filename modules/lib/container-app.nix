{ config, lib, pkgs }:

{ containerPort ? 8080, extraConfig ? (cfg: {}), hostName, name }:

with lib;

let
  cfg = config.custom.applications.${name};
in

{

  ###### interface

  options = {

    custom.applications.${name} = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to install ${hostName}.
        '';
      };

      containerAddress = mkOption {
        type = types.str;
        default = "10.233.${toString cfg.containerID}.2";
        description = ''
          Container address.
        '';
      };

      containerID = mkOption {
        type = types.int;
        default = 1;
        description = ''
          Container ID.
        '';
      };

      containerPort = mkOption {
        type = types.int;
        default = containerPort;
        description = ''
          Container port.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable (
    mkMerge [
      {
        custom.services.nginx.enable = true;

        services.nginx.virtualHosts.${hostName} = {
          enableACME = true;
          forceSSL = true;
          locations."/".proxyPass = "http://${cfg.containerAddress}:${toString cfg.containerPort}/";
        };
      }

      (extraConfig cfg)
    ]
  );

}
