{ config, pkgs, ... }:

{
  imports = [
    ./lib/interface.nix
  ];

  custom = {
    desktop = {
      enable = true;
      laptop = true;
    };

    dev.enable = true;
  };

  networking.hostName = "argon";
}
