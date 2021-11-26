{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom = {
    base.general.lightWeight = true;

    development.nix.nixos.enable = true;
  };
}
