{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.fzf;
in

{

  ###### interface

  options = {

    custom.programs.fzf.enable = mkEnableOption "fzf config";

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
