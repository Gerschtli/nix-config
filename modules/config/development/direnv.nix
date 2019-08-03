{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.development.direnv;
in

{

  ###### interface

  options = {

    custom.development.direnv.enable = mkEnableOption "direnv config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

  };

}
