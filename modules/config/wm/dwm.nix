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
      services = {
        dunst.enable = true;

        dwm-status = {
          inherit (config.custom.base.desktop) laptop;

          enable = true;
        };
      };

      wm.general.enable = true;
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
      ];

      # Fix java applications
      sessionVariables.AWT_TOOLKIT = "MToolkit";
    };

    services.screen-locker = {
      enable = cfg.enableScreenLocker;
      lockCmd = "${lock-screen}/bin/lock-screen";
      inactiveInterval = 20;

      # disable xautolock when cursor is in bottom right corner
      xautolockExtraOptions = [ "-corners" "000-" ];

      # lock before suspending/hibernating, see https://github.com/i3/i3lock/issues/207
      xssLockExtraOptions = [ "--transfer-sleep-lock" ];
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
