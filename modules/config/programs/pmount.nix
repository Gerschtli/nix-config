# FIXME: remove when https://github.com/NixOS/nixpkgs/pull/51406 get merged

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.pmount;
in

{

  ###### interface

  options = {

    custom.programs.pmount = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to install pmount with setuid wrapper.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    security.wrappers = {
      pmount.source = "${pkgs.pmount.out}/bin/pmount";
      pumount.source = "${pkgs.pmount.out}/bin/pumount";
    };

    system.activationScripts.pmount = ''
      mkdir -p /media
    '';

  };

}
