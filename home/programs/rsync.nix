{ config, lib, pkgs, ... }:

let
  inherit (lib)
    concatStringsSep
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.rsync;
in

{

  ###### interface

  options = {

    custom.programs.rsync.enable = mkEnableOption "rsync config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.shell.shellAliases =
      let
        options = [
          "--recursive"
          "--links"
          "--perms"
          "--times"
          "--owner"
          "--group"
          "--devices"
          "--specials"
          "--hard-links"
          "--whole-file"
          "--delete"
          "--cvs-exclude"
          "--prune-empty-dirs"
          "--compress"
          "--stats"
          "--human-readable"
          "--progress"
        ];

        optionsFat = [
          "--chmod='u=rwX,go='"
          "--chown=$(id -u):$(id -g)"
          "--size-only"
        ];

        mkOptions = concatStringsSep " ";
      in
      {
        rsync = "rsync ${mkOptions options}";
        rsync-fat = "rsync ${mkOptions optionsFat}";
      };

    home.packages = [ pkgs.rsync ];

  };

}
