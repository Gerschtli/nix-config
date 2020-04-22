{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.nginx;
in

{

  ###### interface

  options = {

    custom.services.nginx.enable = mkEnableOption "nginx";

  };


  ###### implementation

  config = mkIf cfg.enable {

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    security.acme = {
      acceptTerms = true;
      email = "tobias.happ@gmx.de";
    };

    services.nginx = {
      enable = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;
    };

  };

}
