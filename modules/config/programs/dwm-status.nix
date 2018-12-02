# FIXME: remove when https://github.com/NixOS/nixpkgs/pull/51319 get merged

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.dwm-status;

  order = concatMapStringsSep "," (feature: ''"${feature}"'') cfg.order;

  configFile = pkgs.writeText "dwm-status.toml" ''
    order = [${order}]

    ${cfg.extraConfig}
  '';
in

{

  ###### interface

  options = {

    custom.programs.dwm-status = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable dwm-status user service.
        '';
      };

      order = mkOption {
        type = types.listOf types.str;
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

    services.upower.enable = builtins.elem "battery" cfg.order;

    systemd.user.services.dwm-status = {
      description = "Highly performant and configurable DWM status service";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];

      serviceConfig.ExecStart =
        let
          package = pkgs.dwm-status.override {
            enableAlsaUtils = builtins.elem "audio" cfg.order;
          };
        in
          "${pkgs.dwm-status}/bin/dwm-status ${configFile}";
    };

  };

}
