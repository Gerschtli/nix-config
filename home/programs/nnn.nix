{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.nnn;
in

{

  ###### interface

  options = {

    custom.programs.nnn.enable = mkEnableOption "nnn config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.shell.shellAliases = {
      nnn = "nnn -T v"; # group hidden files
    };

    # FIXME: move env vars to nnn home-manager module
    home.sessionVariables = {
      NNN_OPENER = pkgs.nnn.src + "/plugins/nuke";
      NNN_OPTS = builtins.concatStringsSep "" [
        "D" # dirs in context color
        "H" # show hidden files
        "c" # cli-only NNN_OPENER
        "d" # detail mode
        "o" # open files only on Enter
      ];
    };

    programs.nnn = {
      enable = true;
      package = pkgs.nnn.override { withNerdIcons = true; };

      plugins = {
        src = pkgs.nnn.src + "/plugins";

        mappings = {
          d = "diffs";
          f = "finder";
          o = "fzopen";
          p = "mocplay";
          t = "nmount";
          v = "imgview";
        };
      };
    };

  };

}
