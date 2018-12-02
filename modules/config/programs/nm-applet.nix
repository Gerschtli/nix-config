# FIXME: remove when https://github.com/NixOS/nixpkgs/pull/51379 get merged

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.nm-applet;
in

{

  ###### interface

  options = {

    custom.programs.nm-applet = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable nm-applet.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    systemd.user.services.nm-applet = {
      description = "Network manager applet";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig.ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet";
    };

  };

}
