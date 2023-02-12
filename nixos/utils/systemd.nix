{ config, lib, pkgs, ... }:

let
  inherit (lib)
    attrValues
    flip
    mkDefault
    mkMerge
    mkOption
    types
    ;

  cfg = config.custom.utils.systemd;

  timerOpts = { name, config, ... }: {
    options = {
      name = mkOption {
        type = types.str;
        description = ''
          Name of timer and service.
        '';
      };

      description = mkOption {
        type = types.str;
        description = ''
          Description of timer and service.
        '';
      };

      interval = mkOption {
        type = types.str;
        description = ''
          Systemd calendar expression when to run service. See
          <citerefentry><refentrytitle>systemd.time</refentrytitle>
          <manvolnum>7</manvolnum></citerefentry>.
        '';
      };

      serviceConfig = mkOption {
        type = types.attrs;
        description = ''
          Config for service.
        '';
      };
    };

    config = {
      name = mkDefault name;
    };
  };

in

{

  ###### interface

  options = {

    custom.utils.systemd.timers = mkOption {
      type = with types; attrsOf (submodule timerOpts);
      default = { };
      description = ''
        List of systemd timers with respective service config.
      '';
    };

  };


  ###### implementation

  config = {

    systemd = mkMerge (flip map (attrValues cfg.timers) (
      timer: {
        timers.${timer.name} = {
          description = "${timer.description} timer";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = timer.interval;
            AccuracySec = "5m";
            Unit = "${timer.name}.service";
          };
        };

        services.${timer.name} = mkMerge [
          {
            enable = true;
            description = "${timer.description} service";
            serviceConfig.Type = "oneshot";
          }
          timer.serviceConfig
        ];
      }
    ));

  };

}
