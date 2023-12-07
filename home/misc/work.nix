{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.custom.misc.work;
in

{

  ###### interface

  options = {

    custom.misc.work = {
      enable = mkEnableOption "work related config";

      directory = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Directory in `~/projects` where git projects are saved.
        '';
      };

      mailAddress = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Work related mail address (used for git config).
        '';
      };
    };

  };


  ###### implementation

  config = {

    assertions = [
      {
        assertion = cfg.enable -> cfg.directory != null && cfg.mailAddress != null;
        message = "You need to set directory and mailAddress when work module is enabled.";
      }
    ];

    custom.misc.work.enable = mkIf (cfg.directory != null || cfg.mailAddress != null) true;

  };

}
