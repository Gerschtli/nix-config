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

      packages = mkOption {
        type = types.listOf types.package;
        default = [];
        description = ''
          List of packages.
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
      type = with types; attrsOf (submodule opts);
      default = { };
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
          # FIXME: move mkIf to ids module
          gid = mkIf config.custom.ids.enable config.custom.ids.gids.${user.name};
        };

        users.${user.name} = {
          inherit (user) createHome packages;

          # FIXME: move mkIf to ids module
          uid = mkIf config.custom.ids.enable config.custom.ids.uids.${user.name};
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
