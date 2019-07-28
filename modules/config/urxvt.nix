{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.urxvt;
in

{

  ###### interface

  options = {

    custom.urxvt.enable = mkEnableOption "urxvt config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    home.packages = [ pkgs.rxvt_unicode-with-plugins ];

    xresources.properties =
      let
        colorBlue = "#6d68ff";
        fontName = "UbuntuMono Nerd Font";
        fontSize = "11";
      in
        {
          "Xft.dpi"                   = "96";
          "Xft.antialias"             = "true";
          "Xft.rgba"                  = "rgb";
          "Xft.hinting"               = "true";
          "Xft.hintstyle"             = "hintslight";

          "URxvt*background"          = "black";
          "URxvt*boldFont"            = "xft:${fontName}:bold:pixelsize=${fontSize}";
          "URxvt*boldItalicFont"      = "xft:${fontName}:bold:italic:pixelsize=${fontSize}";
          "URxvt*font"                = "xft:${fontName}:pixelsize=${fontSize}";
          "URxvt*foreground"          = "white";
          "URxvt*italicFont"          = "xft:${fontName}:italic:pixelsize=${fontSize}";
          "URxvt*modifier"            = "alt";
          "URxvt*scrollBar"           = "false";

          "URxvt*perl-ext-common"     = "default,font-size,keyboard-select,selection-to-clipboard,url-select";

          "URxvt.keysym.C-minus"      = "perl:font-size:decrease";
          "URxvt.keysym.C-plus"       = "perl:font-size:increase";
          "URxvt.keysym.C-equal"      = "perl:font-size:reset";
          "URxvt.font-size.step"      = "2";

          "URxvt.keysym.M-s"          = "perl:keyboard-select:activate";
          "URxvt.keysym.M-r"          = "perl:keyboard-select:search";

          "URxvt.keysym.M-u"          = "perl:url-select:select_next";
          "URxvt.url-select.launcher" = "${pkgs.google-chrome}/bin/google-chrome-stable";

          "URxvt*color4"              = colorBlue;
          "URxvt*color12"             = colorBlue;
        };

  };

}
