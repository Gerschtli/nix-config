{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom.programs.pass = {
    enable = true;
    ncurses = true;
  };
}
