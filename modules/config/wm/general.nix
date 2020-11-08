{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.wm.general;
in

{

  ###### interface

  options = {

    custom.wm.general.enable = mkEnableOption "common config for window-managers";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.urxvt.enable = true;

    home.packages = [
      (pkgs.writeScriptBin "inhibit-suspend" ''
        #!${pkgs.runtimeShell} -e
        # Disable suspend on lid close until screen gets unlocked

        ${pkgs.systemd}/bin/systemd-inhibit --what=handle-lid-switch lock-screen
      '')
    ] ++ (
      map
        (item: pkgs.writeScriptBin
          (if item ? name then item.name else item.command)
          ''
            #!${pkgs.runtimeShell} -e

            if ${pkgs.gnome3.zenity}/bin/zenity --question \
                --text="Are you sure you want to ${item.message}?" 2> /dev/null; then
              ${if item ? sudo && item.sudo then "sudo systemctl" else "${pkgs.systemd}/bin/systemctl"} ${item.command}
            fi
          ''
        )
        [
          { command = "poweroff"; name = "halt";       message = "halt the system"; }
          { command = "hibernate";                     message = "suspend to disk"; sudo = cfg.useSudoForHibernate; }
          { command = "hybrid-sleep";                  message = "suspend to disk and ram"; }
          { command = "reboot";                        message = "reboot"; }
          { command = "suspend"; name = "sys-suspend"; message = "suspend to ram"; }
        ]
    );

    services = {
      network-manager-applet.enable = config.custom.base.desktop.laptop;

      unclutter = {
        enable = true;
        timeout = 3;
      };
    };

  };

}
