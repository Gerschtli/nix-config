{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.ip-watcher.server;
in

{

  ###### interface

  options = {

    custom.services.ip-watcher.server = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable the ip-watcher server module.
        '';
      };

      group = mkOption {
        type = types.str;
        default = cfg.user;
        description = ''
          Group name.
        '';
      };

      user = mkOption {
        type = types.str;
        default = "ip-watcher";
        description = ''
          User name.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.utils.systemUsers.${cfg.user} = {
      inherit (cfg) group;
      createHome = true;

      sshKeys = [
        ../../../files/keys/id_rsa.ip-watcher.pub
      ];
    };

  };

}
