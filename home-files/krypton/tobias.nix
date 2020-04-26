{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom.programs = {
    gpg.curses = true;

    pass.enable = true;
  };
}
