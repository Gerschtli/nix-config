{ config, lib, pkgs, ... }:

{
  custom = {
    development.nix.nixos.enable = true;

    programs = {
      gpg.curses = true;

      pass.enable = true;
    };
  };
}
