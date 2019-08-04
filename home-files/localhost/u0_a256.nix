{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom = {
    misc.dotfiles.enable = true;

    programs = {
      prompts.liquidprompt.config = {
        LP_ENABLE_LOAD = 0;
      };

      ssh = {
        enableKeychain = false;
        modules = [ "private" ];
      };
    };
  };

  home.packages = with pkgs; [
    nix
    cacert
    coreutils
    bashInteractive

    glibc
    glibcLocales
    gawk
    procps
    ncurses
    diffutils
    findutils
    gnugrep
    gnused
    hostname
    man
    openssh
  ];
}
