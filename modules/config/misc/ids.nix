{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.ids;
in

{

  ###### interface

  options = {

    custom.ids = {
      enable = mkEnableOption "custom uids and gids" // { default = true; };

      uids = mkOption {
        type = types.attrs;
        readOnly = true;
        description = ''
          The user IDs used in custom NixOS configuration.
        '';
      };

      gids = mkOption {
        type = types.attrs;
        readOnly = true;
        description = ''
          The group IDs used in custom NixOS configuration.
        '';
      };
    };

  };


  ###### implementation

  config = {

    custom.ids = {
      uids = {
        backup = 500;
        storage = 501;
        ip-watcher = 502;

        tobias = 1000;
      };

      gids = {
        backup = 500;
        storage = 501;
        ip-watcher = 502;

        secret-files = 600;
      };
    };

  };

}
