{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.programs.bash;
in

{

  ###### interface

  options = {

    custom.programs.bash.enable = mkEnableOption "bash config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.shell.enable = true;

    programs.bash = {
      enable = true;
      historySize = 1000;
      historyFileSize = 2000;
      historyControl = [ "ignorespace" "ignoredups" ];

      # mkBefore is needed because hashing needs to be enabled early in the config
      initExtra = mkBefore ''
        # enable hashing
        set -h
      '';
    };

  };

}
