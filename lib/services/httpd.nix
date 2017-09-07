{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.httpd;
in

{

  ###### interface

  options = {

    custom.services.httpd = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to install and configure httpd.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    services.httpd = {
      enable = true;
      logPerVirtualHost = true;
      adminAddr = "tobias.happ@gmx.de";
    };

  };

}
