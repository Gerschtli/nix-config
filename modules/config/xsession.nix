{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.xsession;

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

    custom.xsession = {

      enable = mkEnableOption "xsession config";

      # FIXME: i3lock throws error on ubuntu: "i3lock-color: Cannot grab pointer/keyboard"
      useSlock = mkEnableOption "slock as screen locker";

      useSudoForHibernate = mkEnableOption "to use sudo for hibernate command";

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.shell.shellAliases = {
      fix-java = "${pkgs.wmname}/bin/wmname LG3D && export AWT_TOOLKIT=MToolkit";
    };

    home = {
      keyboard = {
        layout = "de";
        options = [ "ctrl:nocaps" ];
        variant = "nodeadkeys";
      };

      packages = with pkgs; [
        dmenu
        dwm
        google-chrome
        lock-screen
        nomacs
        pavucontrol
        playerctl
        qpdfview
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
    };

    services.screen-locker = {
      enable = true;
      lockCmd = "${lock-screen}/bin/lock-screen";
      inactiveInterval = 20;

      # disable xautolock when cursor is in bottom right corner
      xautolockExtraOptions = [ "-corners" "000-" ];

      # lock before suspending/hibernating, see https://github.com/i3/i3lock/issues/207
      xssLockExtraOptions = [ "--transfer-sleep-lock" ];
    };

    systemd.user.startServices = true;

    xdg.mimeApps = {
      enable = true;

      defaultApplications = {
        "application/pdf" = "qpdfview.desktop";

        "image/jpeg" = "nomacs.desktop";
        "image/png" = "nomacs.desktop";

        "message/rfc822" = "thunderbird.desktop";
        "x-scheme-handler/mailto" = "thunderbird.desktop";

        "text/html" = "google-chrome.desktop";
        "x-scheme-handler/http" = "google-chrome.desktop";
        "x-scheme-handler/https" = "google-chrome.desktop";
        "x-scheme-handler/about" = "google-chrome.desktop";
        "x-scheme-handler/unknown" = "google-chrome.desktop";
      };
    };

    xsession = {
      enable = true;
      windowManager.command = "${pkgs.dwm}/bin/dwm";

      numlock.enable = true;

      initExtra = ''
        # Show screen saver after 20 min
        ${pkgs.xorg.xset}/bin/xset s 1200
        # Disable screen power saving settings
        ${pkgs.xorg.xset}/bin/xset -dpms
        # Increase key repeat speed
        ${pkgs.xorg.xset}/bin/xset r rate 250 30

        # Send notification if last nix-channel --update is more than a week ago
        if [[ $(find /nix/var/nix/profiles/per-user -type l -iname "channels-*" -mtime -7 | wc -l) == 0 ]]; then
            ${pkgs.libnotify}/bin/notify-send "Please update me!" \
              "Last time you updated your nix-channel is more than a week ago.. :("
        fi
      '';
    };

  };

}
