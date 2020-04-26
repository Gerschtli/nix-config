{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.programs.pass;
in

{

  ###### interface

  options = {

    custom.programs.pass = {
      enable = mkEnableOption "pass config";

      desktop = mkEnableOption "desktop settings";
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.gpg.enable = true;

    programs = {
      # FIXME: does not work, see https://github.com/rycee/home-manager/issues/786
      # browserpass.enable = cfg.desktop;

      password-store = {
        enable = true;
        package =
          with pkgs.nur-gerschtli;
          if cfg.desktop then pass-x11 else pass;
      };
    };

  };

}
