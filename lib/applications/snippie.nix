{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.applications.snippie;

  hostName = "snippie.de";
  containerAddress = "10.233.1.2";
  containerPort = "8080";
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

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.services.nginx.enable = true;

    services.nginx = {
      virtualHosts."${hostName}" = {
        locations."/".proxyPass = "http://${containerAddress}:${containerPort}/";
      };
    };

  };

}
