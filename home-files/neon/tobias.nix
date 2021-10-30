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
        directories = [
          "~/Documents/finance"
          "~/Documents/general"
          "~/Documents/sbb-kassenwart"
        ];
      };

      sdks = {
        enable = true;
        links = {
          inherit (pkgs) jdk11;
        };
      };
    };

    programs.go.enable = true;

    services.dwm-status.backlightDevice = "amdgpu_bl1";

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

  xsession.initExtra = ''
    xinput set-prop "UNIW0001:00 093A:0255 Touchpad" "Coordinate Transformation Matrix" 5 0 0 0 5 0 0 0 1
  '';
}
