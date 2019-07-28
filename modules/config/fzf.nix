{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.fzf;
in

{

  ###### interface

  options = {

    custom.fzf.enable = mkEnableOption "fzf config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    programs.fzf = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

  };

}
