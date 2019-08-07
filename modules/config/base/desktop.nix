{ config, lib, pkgs, ... } @ args:
with lib;

let
  cfg = config.custom.base.desktop;
in

{

  ###### interface

  options = {

    custom.base.desktop = {

      enable = mkEnableOption "desktop setup";

      laptop = mkEnableOption "laptop config";

      personal = mkEnableOption "personal desktop config";

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom = {
      development.lorri.enable = true;

      misc.dotfiles = {
        enable = true;
        modules = [ "atom" ];
      };

      programs = {
        pass = mkIf cfg.personal {
          enable = true;
          browserpass = true;
          x11Support = true;
        };

        ssh.modules = [ "private" ];

        urxvt.enable = true;
      };

      services = {
        dunst.enable = true;

        dwm-status = {
          enable = true;
          order = if cfg.laptop
            then [ "cpu_load" "backlight" "audio" "battery" "time" ]
            else [ "cpu_load" "audio" "time" ];

          extraConfig = ''
            separator = "    "

            [audio]
            mute = "ﱝ"
            template = "{ICO} {VOL}%"
            icons = ["奄", "奔", "墳"]

            ${optionalString cfg.laptop ''
              [backlight]
              template = "{ICO} {BL}%"
              icons = ["", "", ""]

              [battery]
              charging = ""
              discharging = ""
              no_battery = ""
              icons = ["", "", "", "", "", "", "", "", "", "", ""]
            ''}
          '';
        };
      };

      xsession.enable = true;
    };

    home.packages = with pkgs; [
      gimp
      jetbrains.idea-ultimate
      libreoffice
      postman
      spotify
    ] ++ (optionals cfg.personal [
      audacity
      musescore
      thunderbird
    ]);

    services.unclutter = {
      enable = true;
      timeout = 3;
    };

  };

}
