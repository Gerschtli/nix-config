{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.teamspeak-update-notifier;

  configFile = pkgs.writeText "config.ini" ''
    [ts3]
    host = 127.0.0.1
    port = 10011
    username = serveradmin
    password = ${import (config.lib.custom.path.secrets + "/teamspeak-serverquery-password")}
    server_id = 1

    [notifier]
    server_group_id = 6
    current_version = ${lib.getVersion pkgs.teamspeak_server.name}
  '';
in

{

  ###### interface

  options = {

    custom.programs.teamspeak-update-notifier.enable = mkEnableOption "teamspeak-update-notifier";

  };


  ###### implementation

  config = mkIf cfg.enable {

    systemd.services.teamspeak-update-notifier = {
      description = "Teamspeak update notifier service";

      after = [ "teamspeak3-server.service" ];
      requires = [ "teamspeak3-server.service" ];
      wantedBy = [ "multi-user.target" "teamspeak3-server.service" ];

      serviceConfig = {
        DynamicUser = true;
        ExecStart = "${pkgs.nur-gerschtli.teamspeak-update-notifier}/bin/teamspeak-update-notifier ${configFile}";
        Restart = "always";
        RestartSec = 30;
      };
    };

  };

}
