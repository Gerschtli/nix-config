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
in

{

  imports = [ <agenix/modules/age.nix> ];


  ###### interface

  options = {

    custom.agenix.secrets = mkOption {
      type = types.listOf (types.enum [
        "gitea-dbpassword"
        "id-rsa-backup"
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
          name = "teamspeak-serverquery-password";
          host = "krypton";
          user = "teamspeak-update-notifier";
        })

      ];

      sshKeyPaths =
        let
          add = file: optional (pathExists file) file;
        in
        (add "/root/.age-bak/key.txt")
        ++ (add "/root/.age/key.txt");
    };

  };

}
