{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.wm.general;

  lockScreenPackage =
    config.lib.custom.mkScript
      "lock-screen"
      ./lock-screen.sh
      [ pkgs.i3lock-fancy pkgs.scrot pkgs.xorg.xset ]
      { };
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

      (config.lib.custom.mkScript
        "inhibit-suspend"
        ./inhibit-suspend.sh
        [ lockScreenPackage pkgs.systemd ]
        { }
      )
    ] ++ (
      map
        (item:
          config.lib.custom.mkScript
            (if item ? name then item.name else item.command)
            ./wm-script.sh
            [ pkgs.gnome3.zenity pkgs.systemd ]
            { inherit (item) command message; }
        )
        [
          { command = "poweroff"; name = "halt"; message = "halt the system"; }
          { command = "hibernate"; message = "suspend to disk"; }
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

  };

}
