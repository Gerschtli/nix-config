{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.redis;
in

{

  ###### interface

  options = {

    custom.services.redis.enable = mkEnableOption "redis";

  };


  ###### implementation

  config = mkIf cfg.enable {

    services.redis = {
      enable = true;
      requirePass = config.lib.custom.path.secrets + "/redis";
    };

  };

}
