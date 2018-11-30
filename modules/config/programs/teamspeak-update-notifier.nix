{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.teamspeak-update-notifier;

  configFile = pkgs.writeText "config.ini" ''
    [ts3]
    host = 127.0.0.1
    port = 10011
    username = serveradmin
    password = ${import ../../secrets/teamspeak-serverquery-password}
    server_id = 1

    [notifier]
    server_group_id = 6
    current_version = ${lib.getVersion pkgs.teamspeak_server.name}
  '';
in

{

  ###### interface

  options = {

    custom.services.teamspeak-update-notifier = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to install and configure teamspeak-update-notifier.
        '';
      };

      user = mkOption {
        type = types.str;
        default = "teamspeak-update-notifier";
        description = ''
          User name.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.utils.systemUsers.${cfg.user} = { };

    systemd.services.teamspeak-update-notifier = {
      description = "Teamspeak update notifier service";

      after = [ "teamspeak3-server.service" ];
      requires = [ "teamspeak3-server.service" ];
      wantedBy = [ "multi-user.target" "teamspeak3-server.service" ];

      serviceConfig = {
        User = cfg.user;
        ExecStart = "${pkgs.teamspeak-update-notifier}/bin/teamspeak-update-notifier ${configFile}";
        Restart = "always";
        RestartSec = 30;
      };
    };

  };

}
