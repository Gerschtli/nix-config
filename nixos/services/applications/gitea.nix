{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

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

    custom = {
      agenix.secrets = [ "gitea-dbpassword" ];

      services.backup.services.gitea = {
        inherit (config.services.gitea) user;
        description = "Gitea";
        interval = "Tue *-*-* 04:00:00";

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
    };

    services = {
      gitea = {
        enable = true;
        database.passwordFile = config.age.secrets.gitea-dbpassword.path;
        rootUrl = "https://${domain}/";

        settings.service = {
          COOKIE_SECURE = true;
          DISABLE_REGISTRATION = true;
          REQUIRE_SIGNIN_VIEW = true;
        };
      };

      nginx.virtualHosts.${domain} = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://localhost:${toString giteaCfg.httpPort}/";
      };
    };

  };

}
