{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.arduino;
in

{

  ###### interface

  options = {

    custom.programs.arduino.enable = mkEnableOption "arduino";

  };


  ###### implementation

  config = mkIf cfg.enable {

    users.users.tobias = {
      extraGroups = [ "tty" "dialout" ];
      packages = [ pkgs.arduino ];
    };

  };

}
