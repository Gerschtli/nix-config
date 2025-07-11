{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.applications.original-chattengauer;

  domain = "original-chattengauer.de";
in

{

  ###### interface

  options = {

    custom.applications.original-chattengauer.enable = mkEnableOption domain;

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.services.nginx.enable = true;

    security.acme.certs.${domain}.extraDomainNames = [ "www.${domain}" ];

    services.nginx.virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;
      serverAliases = [ "www.${domain}" ];
      locations."/".extraConfig = "rewrite ^/.*$ https://www.chattengauer-gudensberg.de/ permanent;";
    };

  };

}
