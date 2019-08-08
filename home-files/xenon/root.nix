{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom = {
    base.general.lightWeight = true;

    misc.nix-channels = {
      enable = true;
      small = true;
    };
  };
}
