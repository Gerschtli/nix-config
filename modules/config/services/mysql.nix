{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.mysql;
in

{

  ###### interface

  options = {

    custom.services.mysql = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to install and configure mysql (MariaDB).
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    services.mysql = {
      # set password with:
      # SET PASSWORD FOR root@localhost = PASSWORD('password');
      enable = true;
      package = pkgs.mariadb;
    };

  };

}
