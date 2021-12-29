{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.alacritty;
in

{

  ###### interface

  options = {

    custom.programs.alacritty.enable = mkEnableOption "alacritty config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    programs.alacritty = {
      enable = true;

      settings = {
        env.TERM = "screen-256color";

        font = {
          normal.family = "UbuntuMono Nerd Font";
          bold.family = "UbuntuMono Nerd Font";
          italic.family = "UbuntuMono Nerd Font";
          bold_italic.family = "UbuntuMono Nerd Font";
          size = 10;
        };

        colors = {
          primary = {
            background = "#000000";
            foreground = "#ffffff";
          };

          normal = {
            black = "#000000";
            red = "#cd0000";
            green = "#00cd00";
            yellow = "#cdcd00";
            blue = "#6d68ff";
            magenta = "#cd00cd";
            cyan = "#00cdcd";
            white = "#e5e5e5";
          };

          bright = {
            black = "#7f7f7f";
            red = "#ff0000";
            green = "#00ff00";
            yellow = "#ffff00";
            blue = "#8d88ff";
            magenta = "#ff00ff";
            cyan = "#00ffff";
            white = "#ffffff";
          };
        };
      };
    };

  };

}
