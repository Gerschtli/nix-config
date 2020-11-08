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

    ${if cfg.useSlock then "slock" else ''
      ${pkgs.i3lock-fancy}/bin/i3lock-fancy --nofork --text "" -- ${pkgs.scrot}/bin/scrot --silent --overwrite
    ''}

    revert
  '';
in

{

  ###### interface

  options = {

    custom.wm.general = {
      enable = mkEnableOption "common config for window-managers";

      # FIXME: i3lock throws error on ubuntu: "i3lock-color: Cannot grab pointer/keyboard"
      useSlock = mkEnableOption "slock as screen locker";

      useSudoForHibernate = mkEnableOption "to use sudo for hibernate command";

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
