# FIXME: remove when https://github.com/NixOS/nixpkgs/pull/51319 get merged

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.dwm-status;

  order = concatMapStringsSep "," (feature: ''"${feature}"'') cfg.order;

  configFile = pkgs.writeText "dwm-status.toml" ''
    order = [${order}]

    ${cfg.extraConfig}
  '';
in

{

  ###### interface

  options = {

    custom.services.dwm-status = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable dwm-status user service.
        '';
      };

      order = mkOption {
        type = types.listOf (types.enum [ "audio" "backlight" "battery" "cpu_load" "network" "time" ]);
        description = ''
          List of enabled features in order.
        '';
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Extra config in TOML format.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    systemd.user.services.dwm-status = {
      Unit = {
        Description = "Highly performant and configurable DWM status service";
        PartOf = [ "graphical-session.target" ];
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${pkgs.dwm-status}/bin/dwm-status ${configFile}";
      };
    };

  };

}
