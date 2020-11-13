{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom = {
    base.desktop = {
      enable = true;
      laptop = true;
      private = true;
    };

    misc.sdks = {
      enable = true;
      links = {
        inherit (pkgs) jdk11 python37;
        go-1-15 = pkgs.go;
      };
    };

    programs.go.enable = true;

    wm.dwm.enable = true;
  };

  home.packages = with pkgs; [
    skypeforlinux
    zoom-us
  ];

  services.blueman-applet.enable = true;
}
