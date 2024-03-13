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

    # Upstream sets this to process which means that subprocesses are not killed and stopping the service does not stop
    # the nix deployment process. Control-group is the default value.
    # Only set to control-group for desktop systems to prevent that system halt might be prevented by orphaned nix
    # processes.
    systemd.services.cachix-agent.serviceConfig.KillMode = mkIf config.custom.base.desktop.enable (mkForce "control-group");

  };

}
