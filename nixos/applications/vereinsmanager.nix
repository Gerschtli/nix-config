{ config, lib, pkgs, rootPath, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.applications.vereinsmanager;

  domain = "vereinsmanager.tobias-happ.de";
in

{

  ###### interface

  options = {

    custom.applications.vereinsmanager.enable = mkEnableOption "vereinsmanager";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.services.nginx.enable = true;

    services.nginx.virtualHosts.${domain} = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://127.0.0.1:8090/";
    };

    users.users.vereinsmanager = {
      isNormalUser = true;
      group = "docker";
      openssh.authorizedKeys.keyFiles = [
        "${rootPath}/files/keys/id_rsa.vereinsmanager.pub"
      ];
    };

  };

}
