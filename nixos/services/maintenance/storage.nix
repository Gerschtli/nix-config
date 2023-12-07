{ config, lib, pkgs, ... }:

let
  inherit (lib)
    concatMapStringsSep
    mkEnableOption
    mkIf
    mkOption
    types
    ;

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
          Systemd calendar expression when to sync the backups. See {manpage}`systemd.time(7)`.
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
        default = [ ];
        description = ''
          List of server using the backup module.
        '';
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom = {
      agenix.secrets = [ "id-rsa-backup" ];

      utils = {
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
            # FIXME replace with systemd tmpfiles
            preStart = ''
              mkdir -p ${backupDir}
              chown ${user}:${user} ${backupDir}
              chmod 0750 ${backupDir}
            '';
            script = ''
              cd ${backupDir}

              ${
                concatMapStringsSep
                  "\n"
                  (server: ''
                    ${pkgs.rsync}/bin/rsync \
                      --archive \
                      --compress \
                      --include "*.age" \
                      --prune-empty-dirs \
                      --verbose \
                      --whole-file \
                      --rsh "${pkgs.openssh}/bin/ssh \
                        -o UserKnownHostsFile=/dev/null \
                        -o StrictHostKeyChecking=no \
                        -i ${config.age.secrets.id-rsa-backup.path}" \
                      "${backupUser}@${server.ip}:${config.custom.services.backup.location}/*" \
                      "${backupDir}/${server.name}"
                  '')
                  cfg.server
              }

              find ${backupDir} -type f -mtime +${toString cfg.expiresAfter} -exec rm {} \+
            '';
          };
        };

        systemUsers.${user} = { };
      };
    };

    # FIXME replace with systemd tmpfiles
    system.activationScripts.backup = mkIf (! useMount) ''
      mkdir -p ${location}
    '';

    systemd.mounts = mkIf useMount [
      {
        what = cfg.mountDevice;
        where = location;
        type = "ext4";
        wantedBy = [ "multi-user.target" ];
      }
    ];

  };

}
