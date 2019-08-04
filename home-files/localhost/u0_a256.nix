{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom = {
    misc.dotfiles = {
      enable = true;
      modules = [ "home-manager" ];
    };

    programs = {
      prompts.liquidprompt.config = {
        LP_ENABLE_LOAD = 0;
      };

      ssh = {
        enableKeychain = false;
        controlMaster = "no";
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
