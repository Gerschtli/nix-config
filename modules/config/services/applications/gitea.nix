{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.gitea;
  giteaCfg = config.services.gitea;

  domain = "git.tobias-happ.de";
in

{

  ###### interface

  options = {

    custom.services.gitea = {

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

    custom.services.backup.services.gitea = {
      inherit (config.services.gitea) user;
      description = "Gitea";
      interval = "Tue *-*-* 04:00:00";
      expiresAfter = 28;

      script = ''
        ${pkgs.gitea}/bin/gitea dump -c ${config.services.gitea.stateDir}/custom/conf/app.ini
        chmod g+r *
      '';
    };

    services = {
      gitea = {
        enable = true;
        database.passwordFile = toString ../../../secrets/gitea-dbpassword;
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
