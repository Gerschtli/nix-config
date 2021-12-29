{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.wm.general;

  lockScreenPackage =
    config.lib.custom.mkScript
      "lock-screen"
      ./lock-screen.sh
      [ pkgs.xorg.xset ]
      {
        _doNotClearPath = cfg.useSlock;

        lockCommand =
          if cfg.useSlock
          then "slock"
          else "${pkgs.i3lock-fancy}/bin/i3lock-fancy --nofork --text '' -- ${pkgs.scrot}/bin/scrot --silent --overwrite";
      };
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
      programs.alacritty.enable = true;

      wm.general = { inherit lockScreenPackage; };
    };

    home.packages = [
      lockScreenPackage
      pkgs.pavucontrol
      pkgs.xdg-utils

      (config.lib.custom.mkScript
        "inhibit-suspend"
        ./inhibit-suspend.sh
        [ lockScreenPackage pkgs.systemd ]
        { }
      )
    ] ++ (
      map
        (item:
          let useSudo = item ? sudo && item.sudo; in
          config.lib.custom.mkScript
            (if item ? name then item.name else item.command)
            ./wm-script.sh
            [ pkgs.gnome.zenity ]
            {
              inherit (item) command message;

              _doNotClearPath = useSudo;

              systemctlCommand =
                if useSudo
                then "sudo systemctl"
                else "${pkgs.systemd}/bin/systemctl";
            }
        )
        [
          { command = "poweroff"; name = "halt"; message = "halt the system"; }
          { command = "hibernate"; message = "suspend to disk"; sudo = cfg.useSudoForHibernate; }
          { command = "hybrid-sleep"; message = "suspend to disk and ram"; }
          { command = "reboot"; message = "reboot"; }
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

    xdg.mimeApps = {
      enable = true;

      defaultApplications = {
        "application/pdf" = "qpdfview.desktop";

        "image/jpeg" = "org.nomacs.ImageLounge.desktop";
        "image/png" = "org.nomacs.ImageLounge.desktop";

        "message/rfc822" = "thunderbird.desktop";
        "x-scheme-handler/mailto" = "thunderbird.desktop";

        "text/html" = "google-chrome.desktop";
        "x-scheme-handler/http" = "google-chrome.desktop";
        "x-scheme-handler/https" = "google-chrome.desktop";
        "x-scheme-handler/about" = "google-chrome.desktop";
        "x-scheme-handler/unknown" = "google-chrome.desktop";
      };
    };

  };

}
