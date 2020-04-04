{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.ip-watcher.server;

  user = "ip-watcher";
in

{

  ###### interface

  options = {

    custom.services.ip-watcher.server.enable = mkEnableOption "ip-watcher server module";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.utils.systemUsers.${user} = {
      createHome = true;

      sshKeys = [
        ../../../files/keys/id_rsa.ip-watcher.pub
      ];
    };

  };

}
