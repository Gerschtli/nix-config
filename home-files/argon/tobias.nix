{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom.base.desktop = {
    enable = true;
    laptop = true;
    personal = true;
  };

  services.network-manager-applet.enable = true;
}
