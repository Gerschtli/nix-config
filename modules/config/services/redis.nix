{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.redis;
in

{

  ###### interface

  options = {

    custom.services.redis = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to install and configure redis.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    services.redis = {
      enable = true;
      requirePass = import ../../secrets/redis;
    };

  };

}
