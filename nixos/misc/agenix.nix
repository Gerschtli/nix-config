{ config, lib, pkgs, rootPath, ... }:

with lib;

let
  cfg = config.custom.agenix;

  buildConfig = { name, host, user }: mkIf (elem name cfg.secrets) {
    ${name} = {
      file = "${rootPath}/secrets/${host}/${name}.age";
      owner = user;
      group = user;
    };
  };
in

{

  ###### interface

  options = {

    custom.agenix.secrets = mkOption {
      type = types.listOf (types.enum [
        "gitea-dbpassword"
        "id-rsa-backup"
        "mysql-backup-password"
        "teamspeak-serverquery-password"
      ]);
      default = [ ];
      description = ''
        Secrets to install.
      '';
    };

  };


  ###### implementation

  config = {

    age = {
      secrets = mkMerge [

        (buildConfig {
          name = "gitea-dbpassword";
          host = "krypton";
          user = "gitea";
        })

        (buildConfig {
          name = "id-rsa-backup";
          host = "xenon";
          user = "storage";
        })

        (buildConfig {
          name = "mysql-backup-password";
          host = "argon";
          user = "backup";
        })

        (buildConfig {
          name = "teamspeak-serverquery-password";
          host = "krypton";
          user = "teamspeak-update-notifier";
        })

      ];

      identityPaths = [
        "/root/.age/key.txt"
      ];
    };

  };

}
