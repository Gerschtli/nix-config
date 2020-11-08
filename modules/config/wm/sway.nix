{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.wm.sway;

  dmenuFont = "Ubuntu Mono Nerd Font:size=10";
  fonts = [ "Ubuntu Mono Nerd Font 10" ];

  logFile = "${config.home.homeDirectory}/.sway-log";

  screenshotBin = enableSelect: pkgs.writeScriptBin "screenshot" ''
    ${pkgs.coreutils}/bin/mkdir --parents /tmp/screenshot
    ${pkgs.grim}/bin/grim \
      ${optionalString enableSelect "-g $(${pkgs.slurp}/bin/slurp)"} \
      $(${pkgs.coreutils}/bin/date +"/tmp/screenshot/%Y-%m-%d-%H-%M-%S.png")
  '';
in

{

  ###### interface

  options = {

    custom.wm.sway.enable = mkEnableOption "config for sway";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom = {
      programs.shell.loginExtra = ''
        if [[ "$(tty)" == "/dev/tty1" ]]; then
          echo "===== SWAY STARTUP ($(${pkgs.coreutils}/bin/date +"%Y-%m-%d %H-%M-%S")) =====" >> "${logFile}"
          exec ${config.wayland.windowManager.sway.package}/bin/sway >> "${logFile}" 2>&1
        fi
      '';

      wm.general.enable = true;
    };

    home = {
      file.".Xdefaults".source =
        let xresources = config.home.file.".Xresources";
        in mkIf (xresources.source != null) xresources.source;

      sessionVariables."_JAVA_AWT_WM_NONREPARENTING" = 1;
    };

    wayland.windowManager.sway = {
      enable = true;

      config = {
        inherit fonts;
        modifier = "Mod4";
        terminal = "${config.programs.urxvt.package}/bin/urxvt";
        menu = "${pkgs.nur-gerschtli.dmenu}/bin/dmenu_path | "
          + "${pkgs.nur-gerschtli.dmenu}/bin/dmenu -fn '${dmenuFont}' -nb '#222222' -nf '#bbbbbb' -sb '#540303' -sf '#eeeeee' | "
          + "${pkgs.findutils}/bin/xargs swaymsg exec --";

        input = {
          "type:keyboard" = {
            "xkb_layout" = "de";
            "xkb_variant" = "nodeadkeys";
            "xkb_options" = "ctrl:nocaps";
            "repeat_delay" = "250";
            "repeat_rate" = "30";
            "xkb_numlock" = "enabled";
          };
          "type:touchpad" = {
            "accel_profile" = "flat";
            "tap" = "enabled";
            "tap_button_map" = "lmr";
          };
        };

        floating.criteria = [
          { app_id = "zenity"; }
        ];

        keybindings =
          let
            swayConfig = config.wayland.windowManager.sway.config;
            modifier = swayConfig.modifier;
            exec = command: "exec \"${command}\"";
          in
            mkOptionDefault {
              "${modifier}+Return" = null;
              "${modifier}+Tab" = "workspace back_and_forth";
              "${modifier}+Shift+Return" = exec swayConfig.terminal;
              "${modifier}+Shift+q" = null;
              "${modifier}+Shift+c" = "kill";
              "${modifier}+Shift+r" = "reload";
              "${modifier}+d" = null;
              "${modifier}+p" = exec swayConfig.menu;

              "${modifier}+Ctrl+Left" = "workspace prev";
              "${modifier}+Ctrl+Right" = "workspace next";

              "${modifier}+Alt+p" = exec "${pkgs.qpdfview}/bin/qpdfview";
              "${modifier}+Alt+g" = exec "${pkgs.google-chrome}/bin/google-chrome-stable";
              "${modifier}+Ctrl+s" = exec (screenshotBin false);
              "${modifier}+Shift+s" = exec (screenshotBin true);
              "${modifier}+Ctrl+l" = exec "${config.custom.wm.general.lockScreenPackage}/bin/lock-screen";

              "XF86AudioRaiseVolume" = exec "amixer set Master 1%+";
              "XF86AudioLowerVolume" = exec "amixer set Master 1%-";
              "XF86AudioMute" = exec "amixer set Master toggle";
              "XF86MonBrightnessUp" = exec "light -A 5";
              "XF86MonBrightnessDown" = exec "light -U 5";
              "XF86AudioPlay" = exec "${pkgs.playerctl}/bin/playerctl play-pause";
              "XF86AudioNext" = exec "${pkgs.playerctl}/bin/playerctl next";
              "XF86AudioPrev" = exec "${pkgs.playerctl}/bin/playerctl previous";
              "XF86AudioStop" = exec "${pkgs.playerctl}/bin/playerctl stop";
            };

        bars = [
          {
            inherit fonts;
            position = "top";
            statusCommand = "${pkgs.i3status}/bin/i3status";
          }
        ];
      };
    };

  };

}
