{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.pass;
in

{

  ###### interface

  options = {

    custom.pass = {
      enable = mkEnableOption "pass config";

      ncurses = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to install pinentry ncurses.
        '';
      };

      x11Support = mkOption {
        type = types.bool;
        default = false;
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

    custom.dotfiles.modules = [ "gpg" ];

    home.packages = with pkgs; [
      (pass.override { inherit (cfg) x11Support; })
    ] ++ (optional cfg.ncurses pinentry_ncurses);

    programs.browserpass.enable = cfg.browserpass;

  };

}
