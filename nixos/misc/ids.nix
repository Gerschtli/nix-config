{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mapAttrs
    mkEnableOption
    mkOption
    types
    ;

  cfg = config.custom.ids;

  mapIds = mapAttrs (_name: id: if cfg.enable then id else null);
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
      uids = mapIds {
        backup = 500;
        storage = 501;
        # ip-watcher = 502;
        teamspeak-update-notifier = 503;

        tobias = 1000;
        steini = 1001;
      };

      gids = mapIds {
        backup = 500;
        storage = 501;
        # ip-watcher = 502;
        teamspeak-update-notifier = 503;

        # secret-files = 600;
      };
    };

  };

}
