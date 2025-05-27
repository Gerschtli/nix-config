{ config, lib, pkgs, ... }:

{
  custom = {
    base.desktop = {
      enable = true;
      laptop = true;
      private = true;
    };

    development.nix.nixos.enable = true;

    misc = {
      backup = {
        enable = true;
        directories = [
          "~/Documents/finance"
          "~/Documents/general"
        ];
      };

      sdks = {
        enable = true;
        links = {
          inherit (pkgs) jdk17 python310;
        };
      };
    };

    programs = {
      go.enable = true;

      vscode = {
        enable = true;
        packages = [
          # for plantuml
          pkgs.graphviz
          pkgs.openjdk
        ];
      };
    };

    services.dwm-status.backlightDevice = "amdgpu_bl*";

    wm.dwm.enable = true;
  };

  home.packages = with pkgs; [
    openshot-qt
    portfolio
    vlc
    zoom-us
  ];

  services.blueman-applet.enable = true;

  xsession.initExtra = ''
    xinput set-prop "UNIW0001:00 093A:0255 Touchpad" "Coordinate Transformation Matrix" 2 0 0 0 2 0 0 0 1
  '';
}
