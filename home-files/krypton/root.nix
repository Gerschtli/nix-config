{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom = {
    development.nixos.enable = true;

    misc.nix-channels = {
      enable = true;
      small = true;
    };
  };
}
