{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.custom.programs.docker;
in

{

  ###### interface

  options = {

    custom.programs.docker = {
      enable = mkEnableOption "docker";

      autoPrune = {
        enable = mkEnableOption "docker system prune cronjob";

        interval = mkOption {
          type = types.str;
          default = "Tue *-*-* 03:30:00";
          description = ''
            Systemd calendar expression when to run docker system prune. See {manpage}`systemd.time(7)`.
          '';
        };
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    users.users.tobias.extraGroups = [ "docker" ];

    virtualisation.docker = {
      enable = true;

      autoPrune = {
        inherit (cfg.autoPrune) enable;
        flags = [ "--all" ];
        dates = cfg.autoPrune.interval;
      };
    };

  };

}
