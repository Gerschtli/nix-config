{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.wm.dwm;
in

{

  ###### interface

  options = {

    custom.wm.dwm.enable = mkEnableOption "config for dwm";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom = {
      programs.urxvt.enable = true;

      services = {
        dunst.enable = true;

        dwm-status = {
          inherit (config.custom.base.desktop) laptop;

          enable = true;
        };
      };

      xsession.enable = true;
    };

    services = {
      network-manager-applet.enable = config.custom.base.desktop.laptop;

      unclutter = {
        enable = true;
        timeout = 3;
      };
    };

  };

}
