{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom.development.nix.nixos.enable = true;
}
