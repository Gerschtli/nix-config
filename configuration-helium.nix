{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom = {
    desktop.enable = true;

    services.openssh = {
      enable = true;
      forwardX11 = true;
    };
  };

  networking.hostName = "helium";
}
