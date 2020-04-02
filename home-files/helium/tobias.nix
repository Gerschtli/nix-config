{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom.base.desktop = {
    enable = true;
    private = true;
  };
}
