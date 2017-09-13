{ config, pkgs, ... }:

{
  imports = [
    ./lib/interface.nix
  ];

  custom.server = {
    enable = true;
    rootLogin = true;
  };

  networking.hostName = "krypton";
}
