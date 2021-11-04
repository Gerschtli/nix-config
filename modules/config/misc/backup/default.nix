{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.misc.backup;

  rsyncOptions = [
    "--compress"
    "--cvs-exclude"
    "--delete"
    "--devices"
    "--group"
    "--hard-links"
    "--human-readable"
    "--itemize-changes"
    "--links"
    "--owner"
    "--perms"
    "--progress"
    "--prune-empty-dirs"
    "--recursive"
    "--specials"
    "--times"
    "--update"
    "--whole-file"
  ];
in

{

  ###### interface

  options = {

    custom.misc.backup = {
      enable = mkEnableOption "script to run backups";

      directories = mkOption {
        type = types.listOf types.str;
        default = [];
        example = [ "~/Documents/program" ];
        description = ''
          List of directories to backup.
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
      (config.lib.custom.mkScript
        "local-backup"
        ./local-backup.sh
        [ pkgs.openssh pkgs.rsync ]
        {
          inherit (cfg) directories;
          inherit rsyncOptions;
        }
      )
    ];

  };

}
