{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.agenix;

  buildConfig = { name, host, user }: mkIf (elem name cfg.secrets) {
    ${name} = {
      file = config.lib.custom.path.modules + "/../secrets/${host}/${name}.age";
      owner = user;
      group = user;
    };
  };
  buildSshConfig = { name, path, secret }: mkIf (elem secret cfg.secrets) {
    ${name} = {
      inherit path;
      file = config.lib.custom.path.modules + "/../home-manager-configurations/secrets/ssh/${name}.age";
      owner = "root";
      group = "root";
    };
  };
in

{

  imports = [ <agenix/modules/age.nix> ];


  ###### interface

  options = {

    custom.agenix.secrets = mkOption {
      type = types.listOf (types.enum [
        "gitea-dbpassword"
        "gpg-public-key"
        "id-rsa-backup"
        "ssh-vcs"
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
          name = "gpg-public-key";
          host = "krypton";
          user = "backup";
        })

        (buildConfig {
          name = "id-rsa-backup";
          host = "xenon";
          user = "storage";
        })

        (buildConfig {
          name = "teamspeak-serverquery-password";
          host = "krypton";
          user = "teamspeak-update-notifier";
        })

        (buildSshConfig {
          name = "vcs/config";
          path = "/root/.ssh/config.d/vcs";
          secret = "ssh-vcs";
        })
        (buildSshConfig {
          name = "vcs/id-rsa-vcs";
          path = "/root/.ssh/keys/id_rsa.vcs";
          secret = "ssh-vcs";
        })
        (buildSshConfig {
          name = "vcs/id-rsa-vcs-pub";
          path = "/root/.ssh/keys/id_rsa.vcs.pub";
          secret = "ssh-vcs";
        })

      ];

      sshKeyPaths =
        let
          add = file: optional (pathExists file) file;
        in
        (add "/root/.age-bak/key.txt")
        ++ (add "/root/.age/key.txt");
    };

    custom.agenix.secrets = [ "ssh-vcs" ];

  };

}
