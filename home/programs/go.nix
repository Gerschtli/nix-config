{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.go;
in

{

  ###### interface

  options = {

    custom.programs.go.enable = mkEnableOption "go config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    home.sessionVariables.GOPATH = "${config.home.homeDirectory}/.go";

  };

}
