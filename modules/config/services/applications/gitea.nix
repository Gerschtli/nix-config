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

    custom.services.gitea.enable = mkEnableOption "gitea";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.services.backup.services.gitea = {
      inherit (config.services.gitea) user;
      description = "Gitea";
      interval = "Tue *-*-* 04:00:00";
      expiresAfter = 28;

      script = ''
        pushd ${config.services.gitea.stateDir}
        ${pkgs.gitea}/bin/gitea dump \
          --config ${config.services.gitea.stateDir}/custom/conf/app.ini \
          --work-path ${config.services.gitea.stateDir}
        popd

        mv ${config.services.gitea.stateDir}/gitea-dump-*.zip .
        chmod g+r *
      '';
    };

    services = {
      gitea = {
        enable = true;
        database.passwordFile = config.lib.custom.path.secrets + "/gitea-dbpassword";

        rootUrl = "https://${domain}/";
        cookieSecure = true;
        disableRegistration = true;

        settings.service.REQUIRE_SIGNIN_VIEW = true;
      };

      nginx.virtualHosts.${domain} = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://localhost:${toString giteaCfg.httpPort}/";
      };
    };

  };

}
