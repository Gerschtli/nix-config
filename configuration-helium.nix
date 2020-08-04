{ config, pkgs, ... }:

{
  imports = [ (import ./modules "helium") ];

  custom = {
    base.desktop.enable = true;

    services.openssh = {
      enable = true;
      forwardX11 = true;
    };
  };

  hardware.opengl.driSupport32Bit = true;

  services.xserver = {
    videoDrivers = [ "nvidia" ];

    xrandrHeads = [
      { output = "HDMI-0"; primary = true; }
      { output = "DVI-I-1"; }
    ];
  };
}
