{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.custom.programs.podman;
in

{

  ###### interface

  options = {

    custom.programs.podman = {
      enable = mkEnableOption "podman";

      autoPrune = {
        enable = mkEnableOption "podman system prune cronjob" // {
          default = config.custom.base.server.enable;
        };

        interval = mkOption {
          type = types.str;
          default = "Tue *-*-* 03:30:00";
          description = ''
            Systemd calendar expression when to run podman system prune. See {manpage}`systemd.time(7)`.
          '';
        };
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    virtualisation = {
      oci-containers.backend = "podman";

      podman = {
        enable = true;
        defaultNetwork.settings.dns_enabled = true;

        autoPrune = {
          inherit (cfg.autoPrune) enable;
          flags = [ "--all" ];
          dates = cfg.autoPrune.interval;
        };
      };
    };

  };

}
