{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.pass;
in

{

  ###### interface

  options = {

    custom.programs.pass = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable pass.
        '';
      };

      ncurses = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to install pinentry ncurses.
        '';
      };

      x11Support = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to enable X11 support.
        '';
      };

      browserpass = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to install and configure browserpass.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    programs.browserpass.enable = cfg.browserpass;

    users.users.tobias.packages = with pkgs; [
      gnupg
      (pass.override { inherit (cfg) x11Support; })
    ] ++ (optional cfg.ncurses pinentry_ncurses);

  };

}
