{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.wm.dwm;

  lock-screen = pkgs.writeScriptBin "lock-screen" ''
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

    custom.wm.dwm = {
      enable = mkEnableOption "config for dwm";

      # FIXME: i3lock throws error on ubuntu: "i3lock-color: Cannot grab pointer/keyboard"
      useSlock = mkEnableOption "slock as screen locker";

      useSudoForHibernate = mkEnableOption "to use sudo for hibernate command";

      enableScreenLocker = mkEnableOption "automatic screen locker" // { default = true; };
    };

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
    };

    home = {
      keyboard = {
        layout = "de";
        options = [ "ctrl:nocaps" ];
        variant = "nodeadkeys";
      };

      packages = with pkgs; [
        lock-screen
        nur-gerschtli.dmenu
        nur-gerschtli.dwm
        pavucontrol
        playerctl
        scrot
        xclip
        xorg.xkill

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

      # Fix java applications
      sessionVariables.AWT_TOOLKIT = "MToolkit";
    };

    services = {
      network-manager-applet.enable = config.custom.base.desktop.laptop;

      screen-locker = {
        enable = cfg.enableScreenLocker;
        lockCmd = "${lock-screen}/bin/lock-screen";
        inactiveInterval = 20;

        # disable xautolock when cursor is in bottom right corner
        xautolockExtraOptions = [ "-corners" "000-" ];

        # lock before suspending/hibernating, see https://github.com/i3/i3lock/issues/207
        xssLockExtraOptions = [ "--transfer-sleep-lock" ];
      };

      unclutter = {
        enable = true;
        timeout = 3;
      };
    };

    xsession = {
      enable = true;
      windowManager.command = "${pkgs.nur-gerschtli.dwm}/bin/dwm";

      numlock.enable = true;

      initExtra = ''
        ${optionalString cfg.enableScreenLocker ''
          # Show screen saver after 20 min
          ${pkgs.xorg.xset}/bin/xset s 1200
        ''}
        # Disable screen power saving settings
        ${pkgs.xorg.xset}/bin/xset -dpms
        # Increase key repeat speed
        ${pkgs.xorg.xset}/bin/xset r rate 250 30

        # Send notification if last nix-channel --update is more than a week ago
        if [[ $(find /nix/var/nix/profiles/per-user -type l -iname "channels-*" -mtime -7 | wc -l) == 0 ]]; then
            ${pkgs.libnotify}/bin/notify-send "Please update me!" \
              "Last time you updated your nix-channel is more than a week ago.. :("
        fi

        # Fix java applications, dwm needs to be up and running before executing this command
        for i in 1 2 3; do
          sleep 1
          ${pkgs.wmname}/bin/wmname LG3D
        done &
      '';
    };

  };

}
