{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom = {
    base.desktop = {
      enable = true;
      private = true;
    };

    programs.go.enable = true;

    wm.dwm.enable = true;
  };
}
