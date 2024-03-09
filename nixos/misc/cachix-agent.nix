{ config, lib, pkgs, rootPath, ... }:

let
  inherit (lib)
    mkEnableOption
    mkForce
    mkIf
    ;

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

    # upstream sets this to process which means that subprocesses are not killed and stopping the service does not stop
    # the nix deployment process. control-group is the default value.
    systemd.services.cachix-agent.serviceConfig.KillMode = mkForce "control-group";

  };

}
