{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.docker;
in

{

  ###### interface

  options = {

    custom.programs.docker.enable = mkEnableOption "docker";

  };


  ###### implementation

  config = mkIf cfg.enable {

    users.users.tobias.extraGroups = [ "docker" ];

    virtualisation.docker.enable = true;

  };

}
