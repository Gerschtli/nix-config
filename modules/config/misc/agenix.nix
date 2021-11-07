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
        type = types.listOf (types.enum [ "gitea-dbpassword" ]);
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

    ];

    environment.systemPackages = [
      (import <agenix-cli>).default
    ];

  };

}
