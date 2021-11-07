{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.backup;

  user = "backup";

  serviceOpts = { name, config, ... }: {
    options = {
      name = mkOption {
        type = types.str;
        description = ''
          The name of the service. If undefined, the name of the attribute set
          will be used.
        '';
      };

      description = mkOption {
        type = types.str;
        description = ''
          Description or name of service.
        '';
      };

      user = mkOption {
        type = types.str;
        default = user;
        description = ''
          User to run the backup script with.
        '';
      };

      interval = mkOption {
        type = types.str;
        description = ''
          Systemd calendar expression when to create the backup. See
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

      script = mkOption {
        type = types.str;
        description = ''
          Backup script.
        '';
      };

      extraOptions = mkOption {
        type = types.attrs;
        default = { };
        description = ''
          Extra options for systemd service.
        '';
      };
    };

    config = {
      name = mkDefault name;
    };
  };
in

{

  ###### interface

  options = {

    custom.services.backup = {
      enable = mkEnableOption "backups";

      location = mkOption {
        type = types.str;
        default = "/var/lib/backup";
        readOnly = true;
        description = ''
          Path to backup directory.
        '';
      };

      services = mkOption {
        type = with types; attrsOf (submodule serviceOpts);
        default = { };
        description = ''
          Service configurations for backups with key as service name.
        '';
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom = {
      agenix.secrets = [ "gpg-public-key" ];

      utils = {
        systemd.timers = listToAttrs (flip map (attrValues cfg.services) (
          service:
          let
            location = "${cfg.location}/${service.name}";
            locationGpg = "${location}/gpg-home";
          in

          nameValuePair "${service.name}-backup" {
            inherit (service) interval;
            description = "${service.description} backup";

            serviceConfig = mkMerge [
              {
                serviceConfig = {
                  Group = user;
                  User = service.user;
                };
                preStart = ''
                  mkdir -p ${location} ${locationGpg}
                  chmod 0750 ${location}
                  chmod 0700 ${locationGpg}
                '';
                script = ''
                  cd ${location}
                  ${service.script}

                  find ${location} -type f -not -iname "*.gpg" -exec ${pkgs.gnupg}/bin/gpg2 \
                    --homedir ${locationGpg} --recipient-file /run/secrets/gpg-public-key --encrypt {} \;
                  rm -r ${locationGpg}

                  find ${location} -type f -not -iname "*.gpg" -exec rm -r {} \+
                  find ${location} -mtime +${toString service.expiresAfter} -exec rm -r {} \+
                '';
              }
              service.extraOptions
            ];
          }
        ));

        systemUsers.${user} = {
          home = cfg.location;

          packages = [ pkgs.rsync ];
          sshKeys = [
            (config.lib.custom.path.files + "/keys/id_rsa.backup.pub")
          ];
        };
      };
    };

    system.activationScripts.backup = ''
      mkdir -p ${cfg.location}
      chown ${user}:${user} ${cfg.location}
      chmod 0770 ${cfg.location}
    '';

  };

}
