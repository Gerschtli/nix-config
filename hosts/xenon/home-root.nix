{ config, pkgs, ... }:

{
  custom = {
    base.general.lightWeight = true;

    development.nix.nixos.enable = true;
  };
}
