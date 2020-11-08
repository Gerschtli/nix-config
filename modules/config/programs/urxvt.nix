{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.urxvt;

  colorBlue = "#6d68ff";
  fontName = "UbuntuMono Nerd Font";
  fontSize = "11";

  buildFont = modifier: concatStringsSep ":" (
    [ "xft" fontName ]
      ++ modifier
      ++ [ "pixelsize=${fontSize}" ]
  );
in

{

  ###### interface

  options = {

    custom.programs.urxvt.enable = mkEnableOption "urxvt config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    programs.urxvt = {
      enable = true;
      package = pkgs.rxvt_unicode-with-plugins;

      scroll.bar.enable = false;

      extraConfig = {
        "font" = buildFont [];
        "boldFont" = buildFont [ "bold" ];
        "italicFont" = buildFont [ "italic" ];
        "boldItalicFont" = buildFont [ "bold" "italic" ];

        "background" = "black";
        "foreground" = "white";
        "modifier" = "alt";

        "perl-ext-common" = "default,font-size,keyboard-select,selection-to-clipboard,url-select";

        "font-size.step" = 2;
        "url-select.launcher" = "${pkgs.google-chrome}/bin/google-chrome-stable";

        "color4" = colorBlue;
        "color12" = colorBlue;

        "termName" = "screen-256color";
      };

      keybindings = {
        "C-minus" = "perl:font-size:decrease";
        "C-plus" = "perl:font-size:increase";
        "C-equal" = "perl:font-size:reset";

        "M-s" = "perl:keyboard-select:activate";
        "M-r" = "perl:keyboard-select:search";

        "M-u" = "perl:url-select:select_next";
      };
    };

    xresources.properties = {
      "Xft.dpi" = 96;
      "Xft.antialias" = true;
      "Xft.rgba" = "rgb";
      "Xft.hinting" = true;
      "Xft.hintstyle" = "hintslight";
    };

  };

}
