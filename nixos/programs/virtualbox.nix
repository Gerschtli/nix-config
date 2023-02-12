{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.virtualbox;
in

{

  ###### interface

  options = {

    custom.programs.virtualbox.enable = mkEnableOption "virtualbox";

  };


  ###### implementation

  config = mkIf cfg.enable {

    users.users.tobias.extraGroups = [ "vboxusers" ];

    virtualisation.virtualbox.host.enable = true;

  };

}
