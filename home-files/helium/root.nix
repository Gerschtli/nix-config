{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom.development.nixos.enable = true;
}
