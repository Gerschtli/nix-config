{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.applications.jamulus;

  port = 22124;
in

{

  ###### interface

  options = {

    custom.applications.jamulus.enable = mkEnableOption "jamulus server";

  };


  ###### implementation

  config = mkIf cfg.enable {

    networking.firewall.allowedUDPPorts = [ port ];

    systemd.services.jamulus-server = {
      description = "Jamulus-Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        NoNewPrivileges = true;
        ProtectSystem = true;
        ProtectHome = true;
        Nice = -20;
        IOSchedulingClass = "realtime";
        IOSchedulingPriority = 0;

        ExecStart = concatStringsSep " " [
          "${pkgs.jamulus}/bin/jamulus"
          "--server"
          "--nogui"
          "--port" "${toString port}"
        ];

        Restart = "on-failure";
        RestartSec = 30;
      };
    };

  };

}
