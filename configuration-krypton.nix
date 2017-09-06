{ config, pkgs, ... }:

{
  imports = [
    ./lib/interface.nix
  ];

  custom.server.enable = true;

  networking.hostName = "krypton";
}
