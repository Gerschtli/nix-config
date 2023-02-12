{ config, lib, pkgs, ... }:

let
  inherit (lib)
    concatStringsSep
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.services.minecraft-server;
in

{

  ###### interface

  options = {

    custom.services.minecraft-server.enable = mkEnableOption "minecraft-server";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.services.backup.services.minecraft-server = {
      description = "Minecraft server";
      user = "minecraft";
      interval = "Tue *-*-* 05:10:00";

      directoryToBackup = config.services.minecraft-server.dataDir;

      extraOptions = {
        conflicts = [ "minecraft-server.service" ];
        # FIXME: refactor like described in https://unix.stackexchange.com/a/362883
        serviceConfig.ExecStopPost = "${config.systemd.package}/bin/systemctl start minecraft-server.service";
      };
    };

    services.minecraft-server = {
      enable = true;
      eula = true;
      openFirewall = true;
      jvmOpts = concatStringsSep " " [
        "-Xms4G"
        "-Xmx16G"
      ];
    };

  };

}
