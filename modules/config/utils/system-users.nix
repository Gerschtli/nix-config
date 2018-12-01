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

      group = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Name of group or null, if no group.
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
        groups.${user.group} = mkIf (user.group != null) { };

        users.${user.name} = {
          inherit (user) createHome;
          group = mkIf (user.group != null) user.group;
          isSystemUser = true;
          useDefaultShell = true;
          home = mkIf user.createHome user.home;

          openssh.authorizedKeys.keyFiles = user.sshKeys;
        };
      }

    ));

  };

}
