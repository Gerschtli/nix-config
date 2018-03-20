{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom = {
    desktop.enable = true;

    services.openssh.enable = true;
  };

  hardware.opengl.driSupport32Bit = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  networking.hostName = "helium";
}
