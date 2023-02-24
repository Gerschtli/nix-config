{ config, lib, pkgs, ... }:

{
  custom = {
    base.general.lightWeight = true;

    development.nix.nixos.enable = true;
  };
}
