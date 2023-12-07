{ config, lib, pkgs, rootPath, ... }:

let
  inherit (builtins)
    fromTOML
    ;
  inherit (lib)
    attrValues
    flip
    listToAttrs
    mkDefault
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    nameValuePair
    readFile
    types
    ;

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
          Systemd calendar expression when to create the backup. See {manpage}`systemd.time(7)`.
        '';
      };

      expiresAfter = mkOption {
        type = types.int;
        default = 28;
        description = ''
          Maximum age of backups in days.
        '';
      };


      directoryToBackup = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Directory to backup. Overwrites value in `script`.
        '';
      };

      script = mkOption {
        type = types.nullOr types.str;
        default = null;
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

    config = mkMerge [
      { name = mkDefault name; }

      (mkIf (config.directoryToBackup != null) {
        script = ''
          ${pkgs.gnutar}/bin/tar -cpzf ${name}-$(date +%s).tar.gz -C ${dirOf config.directoryToBackup} ${baseNameOf config.directoryToBackup}
        '';

        extraOptions = {
          path = [ pkgs.gzip ];
        };
      })
    ];
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
        type = types.attrsOf (types.submodule serviceOpts);
        default = { };
        description = ''
          Service configurations for backups with key as service name.
        '';
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.utils = {
      systemd.timers = listToAttrs (flip map (attrValues cfg.services) (
        service:
        let
          location = "${cfg.location}/${service.name}";

          agenixToml = fromTOML (readFile "${rootPath}/.agenix.toml");
          ageKey = agenixToml.identities.bak;
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
              # FIXME replace with systemd tmpfiles
              preStart = ''
                mkdir -p ${location}
                chmod 0750 ${location}
              '';
              script = ''
                cd ${location}
                ${service.script}

                find ${location} -type f -not -iname "*.age" -exec ${pkgs.age}/bin/age \
                  --encrypt --recipient "${ageKey}" --output {}.age {} \;

                find ${location} -type f -not -iname "*.age" -exec rm -r {} \+
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
          "${rootPath}/files/keys/id_rsa.backup.pub"
        ];
      };
    };

    # FIXME replace with systemd tmpfiles
    system.activationScripts.backup = ''
      mkdir -p ${cfg.location}
      chown ${user}:${user} ${cfg.location}
      chmod 0770 ${cfg.location}
    '';

  };

}
