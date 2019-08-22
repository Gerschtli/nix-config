{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom = {
    base.general.lightWeight = true;

    programs.ssh = {
      enableKeychain = false;
      controlMaster = "no";
      modules = [ "private" ];
    };
  };

  home.sessionVariables = {
    LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
  };

  home.packages = with pkgs; [
    cacert
    coreutils
    bashInteractive

    diffutils
    findutils
    gawk
    gnugrep
    gnused
    hostname
    man
    ncurses
  ];
}
