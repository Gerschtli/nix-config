{ config, pkgs, ... }:

{
  imports = [
    ../hardware-configuration.nix
    ./boot.nix
    ./desktop.nix
    ./general.nix
    ./xserver.nix
  ];
}
