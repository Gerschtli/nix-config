{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom = {
    base.general.lightWeight = true;

    development.nixos.enable = true;
  };
}
