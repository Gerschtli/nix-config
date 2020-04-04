{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.utils;

  opts = { name, config, ... }: {

    options = {
      name = mkOption {
        type = types.str;
        description = ''
          Name of user.
        '';
      };

      createHome = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to create home directory.
        '';
      };

      home = mkOption {
        type = types.str;
        default = "/var/lib/${name}";
        description = ''
          Path of home directory.
        '';
      };

      sshKeys = mkOption {
        type = types.listOf types.path;
        default = [];
        description = ''
          List of authorized keys.
        '';
      };
    };

    config = {
      name = mkDefault name;
    };

  };

in

{

  ###### interface

  options = {

    custom.utils.systemUsers = mkOption {
      type = with types; loaOf (submodule opts);
      default = [];
      description = ''
        List of system users.
      '';
    };

  };


  ###### implementation

  config = {

    users = mkMerge (flip map (attrValues cfg.systemUsers) (user:

      {
        groups.${user.name} = {
          gid = config.ids.gids.${user.name};
        };

        users.${user.name} = {
          inherit (user) createHome;

          uid = config.ids.uids.${user.name};
          group = user.name;
          isSystemUser = true;
          useDefaultShell = true;
          home = mkIf user.createHome user.home;

          openssh.authorizedKeys.keyFiles = user.sshKeys;
        };
      }

    ));

  };

}
