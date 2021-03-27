{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom = {
    base.desktop = {
      enable = true;
      laptop = true;
      private = true;
    };

    misc = {
      backup = {
        enable = true;
        config = {
          "~/Documents/finance" = ".";
          "~/Documents/general" = ".";
          "~/Documents/sbb-kassenwart" = ".";
        };
      };

      sdks = {
        enable = true;
        links = {
          inherit (pkgs) jdk14;
        };
      };
    };

    programs.go.enable = true;

    wm.dwm.enable = true;
  };

  home.packages = with pkgs; [
    openshot-qt
    portfolio
    skypeforlinux
    vlc
    zoom-us
  ];

  services.blueman-applet.enable = true;
}
