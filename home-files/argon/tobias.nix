{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom.base.desktop = {
    enable = true;
    laptop = true;
    private = true;
  };

  home.packages = with pkgs; [
    pipenv
    rustup
  ];
}
