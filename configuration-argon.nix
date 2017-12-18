{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom = {
    desktop = {
      enable = true;
      laptop = true;
    };

    # services.openssh.enable = true;
  };

  networking.hostName = "argon";
}
