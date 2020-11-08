{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.wm.sway;

  fonts = [ "Ubuntu Mono Nerd Font 9" ];
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
          exec ${config.wayland.windowManager.sway.package}/bin/sway
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

        bars = [
          {
            inherit fonts;
            mode = "dock";
            hiddenState = "hide";
            position = "top";
            workspaceButtons = true;
            workspaceNumbers = true;
            statusCommand = "${pkgs.i3status}/bin/i3status";
            trayOutput = "primary";
            colors = {
              background = "#000000";
              statusline = "#ffffff";
              separator = "#666666";
              focusedWorkspace = {
                border = "#4c7899";
                background = "#285577";
                text = "#ffffff";
              };
              activeWorkspace = {
                border = "#333333";
                background = "#5f676a";
                text = "#ffffff";
              };
              inactiveWorkspace = {
                border = "#333333";
                background = "#222222";
                text = "#888888";
              };
              urgentWorkspace = {
                border = "#2f343a";
                background = "#900000";
                text = "#ffffff";
              };
              bindingMode = {
                border = "#2f343a";
                background = "#900000";
                text = "#ffffff";
              };
            };
          }
        ];
      };
    };

  };

}
