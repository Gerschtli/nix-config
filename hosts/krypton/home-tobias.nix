{ config, lib, pkgs, ... }:

{
  custom.programs = {
    gpg.curses = true;

    pass.enable = true;
  };
}
