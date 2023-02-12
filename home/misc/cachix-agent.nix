{ config, lib, pkgs, rootPath, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.custom.cachix-agent;
in

{

  ###### interface

  options = {

    custom.cachix-agent = {

      enable = mkEnableOption "cachix-agent";

      hostName = mkOption {
        type = types.str;
        description = "Host name for cachix agent";
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.misc.homeage.secrets = [ "cachix-agent-token-${cfg.hostName}" ];

    services.cachix-agent = {
      enable = true;
      name = cfg.hostName;
      credentialsFile = config.homeage.file."cachix-agent-token-${cfg.hostName}".path;
    };

  };

}
