{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.agenix;
in

{

  imports = [ <agenix/modules/age.nix> ];


  ###### interface

  options = {

    custom.agenix = {
      enable = mkEnableOption "agenix" // {
        default = cfg.secrets != [ ];
      };

      secrets = mkOption {
        type = types.listOf (types.enum [ "gitea-dbpassword" "gpg-public-key" "teamspeak-serverquery-password" ]);
        default = [ ];
        description = ''
          Secrets to install.
        '';
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    age.secrets = mkMerge [

      (mkIf (elem "gitea-dbpassword" cfg.secrets) {
        gitea-dbpassword = {
          file = config.lib.custom.path.modules + "/../secrets/krypton/gitea-dbpassword.age";
          owner = "gitea";
          group = "gitea";
        };
      })

      (mkIf (elem "gpg-public-key" cfg.secrets) {
        gpg-public-key = {
          file = config.lib.custom.path.modules + "/../secrets/krypton/gpg-public-key.age";
          owner = "backup";
          group = "backup";
        };
      })

      (mkIf (elem "teamspeak-serverquery-password" cfg.secrets) {
        teamspeak-serverquery-password = {
          file = config.lib.custom.path.modules + "/../secrets/krypton/teamspeak-serverquery-password.age";
          owner = "teamspeak-update-notifier";
          group = "teamspeak-update-notifier";
        };
      })

    ];

    environment.systemPackages = [
      (import <agenix-cli>).default
    ];

  };

}
