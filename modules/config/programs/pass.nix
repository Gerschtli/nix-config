{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.pass;
in

{

  ###### interface

  options = {

    custom.programs.pass = {
      enable = mkEnableOption "pass config";

      browserpass = mkEnableOption "browserpass";
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.gpg.enable = true;

    programs = {
      # FIXME: does not work, see https://github.com/rycee/home-manager/issues/786
      # browserpass.enable = cfg.browserpass;

      password-store = {
        enable = true;
        package = pkgs.nur-gerschtli.pass;
        settings.PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
      };
    };

  };

}
