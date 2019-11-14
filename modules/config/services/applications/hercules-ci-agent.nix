{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.hercules-ci-agent;
in

{
  imports = [
    (
      builtins.fetchTarball "https://github.com/hercules-ci/hercules-ci-agent/archive/stable.tar.gz"
      + "/module.nix"
    )
  ];


  ###### interface

  options = {

    custom.services.hercules-ci-agent.enable = mkEnableOption "hercules-ci-agent";

  };


  ###### implementation

  config = mkIf cfg.enable {

    services.hercules-ci-agent = {
      enable = true;
      concurrentTasks = 2;
      freespaceGB = null;
    };

  };

}
