{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.gradle;
in

{

  ###### interface

  options = {

    custom.programs.gradle.enable = mkEnableOption "gradle config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    home.packages = [
      (config.lib.custom.mkScript
        "gradle"
        ./gradle.sh
        [ ]
        { _doNotClearPath = true; }
      )
    ];

  };

}
