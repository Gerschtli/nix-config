{ config, pkgs, ... }:

{
  imports = [
    ./lib/interface.nix
  ];

  custom = {
    boot.device = "/dev/sda2";

    desktop = {
      enable = true;
      printing = true;
    };

    dev.enable = true;
  };

  environment.systemPackages = with pkgs; [
    ntfs3g
  ];

  hardware.opengl.driSupport32Bit = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  networking.hostName = "helium";
}
