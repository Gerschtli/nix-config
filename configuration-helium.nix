{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom = {
    boot.device = "/dev/sda2";

    desktop.enable = true;

    # services.openssh.enable = true;
  };

  hardware.opengl.driSupport32Bit = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  networking.hostName = "helium";
}
