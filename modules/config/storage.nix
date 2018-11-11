{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.storage;

  backupDir = "${cfg.location}/backup";
  useMount = cfg.mountDevice != null;
in

{

  ###### interface

  options = {

    custom.storage = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable the storage module.
        '';
      };

      mountDevice = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Optional path to device to mount.
        '';
      };

      location = mkOption {
        type = types.str;
        default = "/storage";
        description = ''
          Path to storage directory.
        '';
      };

      group = mkOption {
        type = types.str;
        default = cfg.user;
        description = ''
          Group name.
        '';
      };

      user = mkOption {
        type = types.str;
        default = "storage";
        description = ''
          User name.
        '';
      };

      interval = mkOption {
        type = types.str;
        description = ''
          Systemd calendar expression when to sync the backups. See
          <citerefentry><refentrytitle>systemd.time</refentrytitle>
          <manvolnum>7</manvolnum></citerefentry>.
        '';
      };

      expiresAfter = mkOption {
        type = types.int;
        description = ''
          Maximum age of backups in days.
        '';
      };

      server = mkOption {
        type = types.listOf (
          types.submodule {
            options = {

              name = mkOption {
                type = types.str;
                description = ''
                  Name of server.
                '';
              };

              ip = mkOption {
                type = types.str;
                description = ''
                  IP of server.
                '';
              };

              location = mkOption {
                type = types.str;
                default = config.custom.backup.location;
                description = ''
                  Backup directory on server.
                '';
              };

              user = mkOption {
                type = types.str;
                default = config.custom.backup.user;
                description = ''
                  Backup user on server.
                '';
              };

            };
          }
        );
        default = [];
        description = ''
          List of server using the backup module.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    system.activationScripts.backup = mkIf (! useMount) ''
      mkdir -p ${cfg.location}
    '';

    systemd = {
      mounts = mkIf useMount [
        {
          what = cfg.mountDevice;
          where = cfg.location;
          type = "ext4";
        }
      ];

      timers.storage-backup = {
        description = "Storage backup timer";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = cfg.interval;
          AccuracySec = "5m";
          Unit = "storage-backup.service";
        };
      };

      services.storage-backup = {
        description = "Storage backup service";
        enable = true;
        serviceConfig = {
          Type = "oneshot";
          Group = cfg.group;
          User = cfg.user;
          PermissionsStartOnly = true;
        };
        unitConfig.RequiresMountsFor = mkIf useMount cfg.location;
        preStart = ''
          mkdir -p ${backupDir}
          chown ${cfg.user}:${cfg.group} ${backupDir}
          chmod 0750 ${backupDir}
        '';
        script = ''
          cd ${backupDir}

          ${foldl (acc: server: ''
            ${acc}
            ${pkgs.rsync}/bin/rsync --archive --verbose --compress --whole-file \
              --rsh "${pkgs.openssh}/bin/ssh \
                -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
                -i ${toString ../secrets/id_rsa.backup}" \
              "${server.user}@${server.ip}:${server.location}/*" \
              ${backupDir}/${server.name}
          '') "" cfg.server}

          find ${backupDir} -type f -mtime +${toString cfg.expiresAfter} -exec rm {} \+
        '';
      };
    };

    users = {
      groups.${cfg.group} = { };

      users.${cfg.user} = {
        inherit (cfg) group;
        isSystemUser = true;
        useDefaultShell = true;
      };
    };

  };

}
