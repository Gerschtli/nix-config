{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    ;

  cfg = config.custom.services.teamspeak;
in

{

  ###### interface

  options = {

    custom.services.teamspeak.enable = mkEnableOption "teamspeak";

  };


  ###### implementation

  config = mkMerge [

    (mkIf (cfg.enable && pkgs.stdenv.hostPlatform.system != "aarch64-linux")
      (
        let
          user = "teamspeak";
          homeDir = "/var/lib/teamspeak";
          dataDir = "${homeDir}/data";
        in
        {

          boot.binfmt.emulatedSystems = [ "x86_64-linux" ];

        services.teamspeak3.enable = true;

          networking.firewall = {
            allowedTCPPorts = [
              10011
              30033
            ];

            allowedUDPPorts = [
              9987
            ];
          };

          systemd.tmpfiles.settings.teamspeak.${dataDir}.d = {
            mode = "700";
            inherit user;
            group = user;
          };

          users = {
            groups.${user} = { };

            users.${user} = {
              isSystemUser = true;
              group = user;
              home = homeDir;
              createHome = true;
              linger = true;

              subUidRanges = [ { startUid = 100000; count = 65536; } ];
              subGidRanges = [ { startGid = 100000; count = 65536; } ];
            };
          };

          virtualisation.oci-containers.containers.teamspeak-server = {
            image = "teamspeak:3.13";
            extraOptions = [
              "--arch=amd64"
            ];
            podman = {
              inherit user;
            };
            autoStart = true;
            environment = {
              TS3SERVER_LICENSE = "accept";
            };
            ports = [
              "9987:9987/udp" # Voice
              "10011:10011/tcp" # ServerQuery
              "30033:30033/tcp" # File Transfer
            ];
            volumes = [
              "${dataDir}:/var/ts3server:Z"
            ];
          };

        }
      )
    )

    (mkIf (cfg.enable && pkgs.stdenv.hostPlatform.system == "aarch64-linux")

      {
        boot.binfmt.emulatedSystems = [ "x86_64-linux" ];

        custom = {
          programs.teamspeak-update-notifier.enable = true;

          services.backup.services.teamspeak3 = {
            description = "Teamspeak3 server";
            user = "teamspeak";
            interval = "Tue *-*-* 05:00:00";

            directoryToBackup = config.services.teamspeak3.dataDir;
          };

          # to prevent accidental restarts, do weekly scheduled restarts
          utils.systemd.timers.teamspeak-restart = {
            description = "teamspeak server restart";
            interval = "Tue *-*-* 07:00:00";

            serviceConfig.script = ''
              ${config.systemd.package}/bin/systemctl try-restart teamspeak3-server.service
            '';
          };
        };

        networking.firewall = {
          allowedTCPPorts = [
            10011
            30033
          ];

          allowedUDPPorts = [
            9987
          ];
        };

        services.teamspeak3.enable = true;

        systemd.services.teamspeak3-server.restartIfChanged = false;

      }

    )
  ];

}
