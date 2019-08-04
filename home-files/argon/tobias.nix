{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom = {
    development = {
      direnv.enable = true;

      lorri.enable = true;
    };

    misc.dotfiles = {
      enable = true;
      modules = [ "atom" ];
    };

    programs = {
      pass = {
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
        order = [ "cpu_load" "backlight" "audio" "battery" "time" ];

        extraConfig = ''
          separator = "    "

          [audio]
          mute = "ﱝ"
          template = "{ICO} {VOL}%"
          icons = ["奄", "奔", "墳"]

          [backlight]
          template = "{ICO} {BL}%"
          icons = ["", "", ""]

          [battery]
          charging = ""
          discharging = ""
          no_battery = ""
          icons = ["", "", "", "", "", "", "", "", "", "", ""]
        '';
      };
    };

    xsession.enable = true;
  };
}
