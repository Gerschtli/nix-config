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
      n = "nnn";
      nnn = "LESS='${config.home.sessionVariables.LESS} -+--quit-if-one-screen -+--no-init' nnn -T v"; # group hidden files
    };

    # FIXME: move env vars to nnn home-manager module
    home.sessionVariables = {
      NNN_OPTS = builtins.concatStringsSep "" [
        "H" # show hidden files
        "d" # detail mode
        "e" # text in $VISUAL/$EDITOR/vi
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
