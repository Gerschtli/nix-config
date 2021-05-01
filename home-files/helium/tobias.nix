{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom = {
    base.desktop = {
      enable = true;
      private = true;
    };

    misc.backup = {
      enable = true;
      config = {
        "~/Documents/finance" = ".";
      };
    };

    misc.sdks = {
      enable = true;
      links = {
        inherit (pkgs.nur-gerschtli) jdk15;
      };
    };

    programs.go.enable = true;

    wm.dwm.enable = true;
  };

  home.packages = with pkgs; [
    nnn
    portfolio
    skypeforlinux
    zoom-us
  ];
}
