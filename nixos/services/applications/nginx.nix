{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

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
      defaults.email = "tobias.happ@gmx.de";
    };

    services.nginx = {
      enable = true;
      enableReload = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      virtualHosts._ = {
        default = true;
        root = "/var/empty";
      };

    };

  };

}
