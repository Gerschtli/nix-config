{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.pass;
in

{

  ###### interface

  options = {

    custom.pass = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable pass.
        '';
      };

      ncurses = mkOption {
        type = types.bool;
        default = config.custom.server.enable;
        description = ''
          Whether to install pinentry ncurses.
        '';
      };

      browserpass = mkOption {
        type = types.bool;
        default = config.custom.desktop.enable;
        description = ''
          Whether to install and configure browserpass.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      gnupg1
      pass
    ] ++ (optional cfg.ncurses pinentry_ncurses);

    programs.browserpass.enable = cfg.browserpass;

  };

}
