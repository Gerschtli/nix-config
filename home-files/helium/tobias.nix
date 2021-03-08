{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom = {
    base.desktop = {
      enable = true;
      private = true;
    };

    misc.sdks = {
      enable = true;
      links = {
        inherit (pkgs) jdk14;
      };
    };

    programs.go.enable = true;

    wm.dwm.enable = true;
  };
}
