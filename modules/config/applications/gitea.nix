{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.applications.gitea;
  giteaCfg = config.services.gitea;

  domain = "git.tobias-happ.de";
in

{

  ###### interface

  options = {

    custom.applications.gitea = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable gitea.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    services = {
      gitea = {
        enable = true;
        database.passwordFile = "/etc/nixos/modules/secrets/gitea-dbpassword";
        rootUrl = "https://${domain}/";
        cookieSecure = true;
        extraConfig = ''
          [service]
          REQUIRE_SIGNIN_VIEW = true
          DISABLE_REGISTRATION = true
        '';
      };

      nginx.virtualHosts.${domain} = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://localhost:${toString giteaCfg.httpPort}/";
      };
    };

  };

}
