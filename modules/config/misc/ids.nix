{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.ids;

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
in

{

  ###### interface

  options = {

    custom.ids = {
      enable = mkEnableOption "custom uids and gids";

      uids = mkOption {
        type = types.attrs;
        readonly = true;
        description = ''
          The user IDs used in custom NixOS configuration.
        '';
      };

      gids = mkOption {
        type = types.attrs;
        readonly = true;
        description = ''
          The group IDs used in custom NixOS configuration.
        '';
      };
    };

  };


  ###### implementation

  config = {

    ids =
      if cfg.enable
      then { inherit uids gids; }
      else
        let
          mapToNull = ids: mapAttrs (name: value: null) ids;
        in
          {
            uids = mapToNull uids;
            gids = mapToNull gids;
          };
  };

}
