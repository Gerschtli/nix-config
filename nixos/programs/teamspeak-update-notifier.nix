{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.teamspeak-update-notifier;

  configFile = pkgs.writeText "config.ini" ''
    [ts3]
    host = 127.0.0.1
    port = 10011
    username = serveradmin
    password_file = ${config.age.secrets.teamspeak-serverquery-password.path}
    server_id = 1

    [notifier]
    server_group_id = 6
  '';

  user = "teamspeak-update-notifier";
in

{

  ###### interface

  options = {

    custom.programs.teamspeak-update-notifier.enable = mkEnableOption "teamspeak-update-notifier";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom = {
      agenix.secrets = [ "teamspeak-serverquery-password" ];

      utils.systemUsers.${user} = { };
    };

    systemd.services.teamspeak-update-notifier = {
      description = "Teamspeak update notifier service";

      after = [ "teamspeak3-server.service" ];
      requires = [ "teamspeak3-server.service" ];
      wantedBy = [ "multi-user.target" "teamspeak3-server.service" ];

      serviceConfig = {
        Group = user;
        User = user;
        ExecStart = "${pkgs.gerschtli.teamspeak-update-notifier}/bin/teamspeak-update-notifier ${configFile}";
        Restart = "always";
        RestartSec = 5;
      };
    };

  };

}
