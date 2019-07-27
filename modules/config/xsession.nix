{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.xsession;

  lock-screen = pkgs.writeScriptBin "lock-screen" ''
    #!${pkgs.bash}/bin/bash

    revert() {
      ${pkgs.xorg.xset}/bin/xset -dpms
    }

    trap revert HUP INT TERM
    ${pkgs.xorg.xset}/bin/xset +dpms dpms 3 3 3

    ${pkgs.i3lock-fancy}/bin/i3lock-fancy --nofork --text "" -- ${pkgs.scrot}/bin/scrot --silent

    revert
  '';
in

{

  ###### interface

  options = {

    custom.xsession.enable = mkEnableOption "xsession config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    home = {
      keyboard = {
        layout = "de";
        options = [ "ctrl:nocaps" ];
        variant = "nodeadkeys";
      };

      packages = with pkgs; [
        dmenu
        dwm # TODO: wrap with runtime dependencies

        (pkgs.writeScriptBin "inhibit-suspend" ''
          #!${pkgs.bash}/bin/bash
          # Disable suspend on lid close until screen gets unlocked

          ${pkgs.systemd}/bin/systemd-inhibit --what=handle-lid-switch lock-screen
        '')

        lock-screen

        # TODO: remove?
        (pkgs.writeScriptBin "chrome" ''
          #!${pkgs.bash}/bin/bash

          ${pkgs.google-chrome}/bin/google-chrome-stable
        '')
      ] ++ (
        map
          (item: pkgs.writeScriptBin
            (if item ? name then item.name else item.command)
            ''
              #!${pkgs.bash}/bin/bash

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
    };

    # TODO: use service after https://github.com/rycee/home-manager/issues/773 got resolved
    services.screen-locker = {
      # enable = true;
      lockCmd = "${lock-screen}/bin/lock-screen";
      inactiveInterval = 20;
    };

    systemd.user.startServices = true;

    xsession = {
      enable = true;
      windowManager.command = "${pkgs.dwm}/bin/dwm";

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
