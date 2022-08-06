{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.httpd;
in

{

  ###### interface

  options = {

    custom.services.httpd.enable = mkEnableOption "httpd";

  };


  ###### implementation

  config = mkIf cfg.enable {

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    security.acme = {
      acceptTerms = true;
      defaults.email = "tobias.happ@gmx.de";
    };

    services.httpd = {
      enable = true;
      adminAddr = "tobias.happ@gmx.de";
    };

  };

}
