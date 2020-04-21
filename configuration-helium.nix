{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom = {
    base = {
      desktop.enable = true;

      general.hostName = "helium";
    };

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
