{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.storage;

  location = "/storage";
  backupDir = "${location}/backup";
  useMount = cfg.mountDevice != null;
  user = "storage";
  backupUser = "backup";
in

{

  ###### interface

  options = {

    custom.services.storage = {

      enable = mkEnableOption "storage module";

      mountDevice = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Optional path to device to mount.
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

    custom.utils = {
      systemd.timers.storage-backup = {
        inherit (cfg) interval;
        description = "Storage backup";

        serviceConfig = {
          serviceConfig = {
            Group = user;
            User = user;
            PermissionsStartOnly = true;
          };
          unitConfig.RequiresMountsFor = mkIf useMount location;
          preStart = ''
            mkdir -p ${backupDir}
            chown ${user}:${user} ${backupDir}
            chmod 0750 ${backupDir}
          '';
          script = ''
            cd ${backupDir}

            ${foldl (acc: server: ''
              ${acc}
              ${pkgs.rsync}/bin/rsync --archive --verbose --compress --whole-file \
                --prune-empty-dirs --include "*/"  --include="*.gpg" --exclude="*" \
                --rsh "${pkgs.openssh}/bin/ssh \
                  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
                  -i ${toString ../../../secrets/id_rsa.backup}" \
                "${backupUser}@${server.ip}:${config.custom.services.backup.location}/*" \
                ${backupDir}/${server.name}
            '') "" cfg.server}

            find ${backupDir} -type f -mtime +${toString cfg.expiresAfter} -exec rm {} \+
          '';
        };
      };

      systemUsers.${user} = { };
    };

    system.activationScripts.backup = mkIf (! useMount) ''
      mkdir -p ${location}
    '';

    systemd.mounts = mkIf useMount [
      {
        what = cfg.mountDevice;
        where = location;
        type = "ext4";
      }
    ];

  };

}
