{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.misc.backup;
in

{

  ###### interface

  options = {

    custom.misc.backup = {
      enable = mkEnableOption "script to run backups";

      config = mkOption {
        type = types.attrs;
        default = {};
        example = literalExample ''
          {
            "~/Documents/program" = ".";
          }
        '';
        description = ''
          Map of source directories or files and their
          destination directories. The basename of source
          path will be the basename in the backup device.
        '';
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs = {
      rsync.enable = true;
      ssh.modules = [ "private" ];
    };

    home.packages = [
      (pkgs.writeScriptBin "local-backup" ''
        #!${pkgs.runtimeShell} -e

        command="${config.custom.programs.shell.shellAliases.rsync}"
        host_name=private.xenon.wlan
        restore=

        while [[ $# -gt 0 ]]; do
          opt="$1"
          shift
          case $opt in
            --dry-run) command="echo rsync" ;;
            --local) host_name=private.local.xenon.wlan ;;
            --restore) restore=1 ;;
            *)
              echo "$0 [--dry-run|--local|--restore]"
              exit 127
              ;;
          esac
        done

        ${concatStringsSep " " (
          mapAttrsToList
            (source: dest: ''
              if [[ -z $restore ]]; then
                $command ${source} "$host_name:/storage/documents/${dest}"
              else
                $command "$host_name:/storage/documents/${dest}/$(basename ${source})" $(dirname ${source})
              fi
            '')
            cfg.config
        )}
      '')

      (pkgs.writeTextFile {
        name = "_local-backup";
        destination = "/share/zsh/site-functions/_local-backup";
        text = ''
          #compdef local-backup

          _arguments \
            "*:options:(--dry-run --local --restore)"
        '';
      })
    ];

  };

}
