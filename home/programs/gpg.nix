{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.gpg;
in

{

  ###### interface

  options = {

    custom.programs.gpg = {
      enable = mkEnableOption "gpg config";

      curses = mkEnableOption "pinentry curses";
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.shell.loginExtra = ''
      # remove existing keys
      if [[ $SHLVL -eq 1 ]]; then
        systemctl --user restart gpg-agent.socket
      fi
    '';

    programs.gpg.enable = true;

    services.gpg-agent = {
      enable = true;
      defaultCacheTtl = 300;

      pinentryPackage = if cfg.curses then pkgs.pinentry-curses else pkgs.pinentry-gtk2;
    };

  };

}
