{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom.misc.nix-channels = {
    enable = true;
    small = true;
  };
}
