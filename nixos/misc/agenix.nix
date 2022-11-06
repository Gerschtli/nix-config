{ config, lib, pkgs, inputs, rootPath, ... }:

with lib;

let
  cfg = config.custom.agenix;

  buildConfig = { name, host, user, fileName ? name }: mkIf (elem name cfg.secrets) {
    ${name} = {
      file = "${rootPath}/secrets/${host}/${fileName}.age";
      owner = user;
      group = user;
    };
  };
in

{

  imports = [ inputs.agenix.nixosModules.age ];


  ###### interface

  options = {

    custom.agenix.secrets = mkOption {
      type = types.listOf (types.enum [
        "cachix-agent-token-argon"
        "cachix-agent-token-krypton"
        "cachix-agent-token-neon"
        "cachix-agent-token-xenon"
        "gitea-dbpassword"
        "id-rsa-backup"
        "mysql-backup-password"
        "teamspeak-serverquery-password"
        "wireless-config"
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
          name = "cachix-agent-token-argon";
          fileName = "cachix-agent-token";
          host = "argon";
          user = "root";
        })

        (buildConfig {
          name = "cachix-agent-token-krypton";
          fileName = "cachix-agent-token";
          host = "krypton";
          user = "root";
        })

        (buildConfig {
          name = "cachix-agent-token-neon";
          fileName = "cachix-agent-token";
          host = "neon";
          user = "root";
        })

        (buildConfig {
          name = "cachix-agent-token-xenon";
          fileName = "cachix-agent-token";
          host = "xenon";
          user = "root";
        })

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

        (buildConfig {
          name = "wireless-config";
          host = "xenon";
          user = "root";
        })

      ];

      identityPaths = [
        "/root/.age/key.txt"
      ];
    };

  };

}
