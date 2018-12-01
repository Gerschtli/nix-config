{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom = {
    base.desktop.enable = true;

    services.openssh = {
      enable = true;
      forwardX11 = true;
    };
  };

  hardware.opengl.driSupport32Bit = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  networking.hostName = "helium";
}
