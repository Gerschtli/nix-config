{ config, pkgs, ... }:

{
  imports = [
    ./lib/interface.nix
  ];

  custom.desktop = {
    enable = true;
    laptop = true;
  };

  networking.hostName = "argon";
}
