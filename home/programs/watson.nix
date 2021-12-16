{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.watson;

  iniFormat = pkgs.formats.ini { };

  configFile = iniFormat.generate "watson-config" {
    options = {
      log_current = true;
      report_current = true;
    };
  };
in

{

  ###### interface

  options = {

    custom.programs.watson.enable = mkEnableOption "watson config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.shell.shellAliases = {
      wsta = "watson start work";
      wsto = "watson stop";
      wwat = "watch --color --interval 1 watson --color log --day";
    };

    home.packages = [ pkgs.watson ];

    xdg.configFile."watson/config".source = configFile;

  };

}
