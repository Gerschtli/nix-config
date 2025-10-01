{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.applications.vaultwarden;
  vaultwardenCfg = config.services.vaultwarden;

  domain = "vaultwarden.tobias-happ.de";
in

{

  ###### interface

  options = {

    custom.applications.vaultwarden.enable = mkEnableOption "vaultwarden";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom = {
      agenix.secrets = [ "vaultwarden-config" ];

      services = {
        backup.services.vaultwarden = {
          description = "Vaultwarden";
          interval = "Tue *-*-* 04:40:00";
          user = "vaultwarden";

          directoryToBackup = vaultwardenCfg.backupDir;
        };

        nginx.enable = true;
      };
    };

    services = {
      vaultwarden = {
        enable = true;
        dbBackend = "sqlite";
        backupDir = "/var/backup/vaultwarden";
        environmentFile = config.age.secrets.vaultwarden-config.path;

        config = {
          ROCKET_PORT = 8000;
          DOMAIN = "https://${domain}";

          SIGNUPS_ALLOWED = false;
        };
      };

      nginx.virtualHosts.${domain} = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString vaultwardenCfg.config.ROCKET_PORT}/";
          proxyWebsockets = true;
        };
      };
    };

  };

}
