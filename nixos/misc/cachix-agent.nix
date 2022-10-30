{ config, lib, pkgs, rootPath, ... }:

with lib;

let
  cfg = config.custom.cachix-agent;

  inherit (config.networking) hostName;
in

{

  ###### interface

  options = {

    custom.cachix-agent.enable = mkEnableOption "cachix-agent";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.agenix.secrets = [ "cachix-agent-token-${hostName}" ];

    services.cachix-agent = {
      enable = true;
      credentialsFile = config.age.secrets."cachix-agent-token-${hostName}".path;
    };

  };

}
