{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.wm.general;

  lockScreenPackage = pkgs.writeScriptBin "lock-screen" ''
    #!${pkgs.runtimeShell} -e

    revert() {
      ${pkgs.xorg.xset}/bin/xset -dpms
    }

    trap revert HUP INT TERM
    ${pkgs.xorg.xset}/bin/xset +dpms dpms 3 3 3

    ${pkgs.i3lock-fancy}/bin/i3lock-fancy --nofork --text "" -- ${pkgs.scrot}/bin/scrot --silent --overwrite

    revert
  '';
in

{

  ###### interface

  options = {

    custom.wm.general = {
      enable = mkEnableOption "common config for window-managers";

      lockScreenPackage = mkOption {
        type = types.package;
        readOnly = true;
        description = "Package with lock-screen executable.";
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom = {
      programs.urxvt.enable = true;

      wm.general = { inherit lockScreenPackage; };
    };

    home.packages = [
      lockScreenPackage
      pkgs.pavucontrol
      pkgs.xdg_utils

      (pkgs.writeScriptBin "inhibit-suspend" ''
        #!${pkgs.runtimeShell} -e
        # Disable suspend on lid close until screen gets unlocked

        ${pkgs.systemd}/bin/systemd-inhibit --what=handle-lid-switch ${lockScreenPackage}/bin/lock-screen
      '')
    ] ++ (
      map
        (item: pkgs.writeScriptBin
          (if item ? name then item.name else item.command)
          ''
            #!${pkgs.runtimeShell} -e

            if ${pkgs.gnome3.zenity}/bin/zenity --question \
                --text="Are you sure you want to ${item.message}?" 2> /dev/null; then
              ${pkgs.systemd}/bin/systemctl ${item.command}
            fi
          ''
        )
        [
          { command = "poweroff"; name = "halt";       message = "halt the system"; }
          { command = "hibernate";                     message = "suspend to disk"; }
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
