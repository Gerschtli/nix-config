{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.services.dwm-status;
in

{

  ###### interface

  options = {

    custom.services.dwm-status = {

      enable = mkEnableOption "dwm-status user service";

      laptop = mkEnableOption "laptop config";

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    services.dwm-status = {
      enable = true;

      order =
        if cfg.laptop
        then [ "cpu_load" "backlight" "audio" "battery" "time" ]
        else [ "cpu_load" "audio" "time" ];

      extraConfig = mkMerge [
        {
          separator = "    ";

          audio = {
            mute = "ﱝ";
            template = "{ICO} {VOL}%";
            icons = [ "奄" "奔" "墳" ];
          };
        }

        (mkIf cfg.laptop {
          backlight = {
            template = "{ICO} {BL}%";
            icons = [ "" "" "" ];
          };

          battery = {
            charging = "";
            discharging = "";
            no_battery = "";
            icons = [ "" "" "" "" "" "" "" "" "" "" "" ];
          };
        })
      ];
    };

  };

}
