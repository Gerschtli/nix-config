{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.shell;
in

{

  ###### interface

  options = {

    custom.shell = {

      enable = mkEnableOption "basic shell config";

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    programs = {
      bash = {
      };
      zsh = {
      };
    };

  };

}
