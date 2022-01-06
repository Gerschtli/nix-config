{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.maven;
in

{

  ###### interface

  options = {

    custom.programs.maven.enable = mkEnableOption "maven config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.shell.shellAliases = {
      maven = "mvn -U clean package -DskipTests=true -Dmaven.compiler.showDeprecation=true -Dmaven.compiler.showWarnings=true";
    };

    home.packages = [
      (config.lib.custom.mkScript
        "mvn"
        ./mvn.sh
        [ ]
        { _doNotClearPath = true; }
      )
    ];

  };

}
