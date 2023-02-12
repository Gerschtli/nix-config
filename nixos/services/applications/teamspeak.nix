{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.services.teamspeak;
in

{

  ###### interface

  options = {

    custom.services.teamspeak.enable = mkEnableOption "teamspeak";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom = {
      programs.teamspeak-update-notifier.enable = true;

      services.backup.services.teamspeak3 = {
        description = "Teamspeak3 server";
        user = "teamspeak";
        interval = "Tue *-*-* 05:00:00";

        directoryToBackup = config.services.teamspeak3.dataDir;
      };
    };

    networking.firewall = {
      allowedTCPPorts = [
        10011
        30033
        41144
      ];

      allowedUDPPorts = [
        9987
      ];
    };

    services.teamspeak3.enable = true;

  };

}
