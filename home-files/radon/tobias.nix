{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom = {
    base = {
      desktop = {
        enable = true;
        laptop = true;
      };

      general.extendedPath = [ "$HOME/bin" ];
    };

    development = {
      nodejs.enable = true;

      php.enable = true;

      vagrant.enable = true;
    };

    misc.util-bins.bins = [ "csv-check" ];

    programs.ssh.modules = [ "pveu" ];

    services.dwm-status.useGlobalAlsaUtils = true;

    xsession = {
      useSlock = true;

      useSudoForHibernate = true;
    };
  };

  home = {
    packages = with pkgs; [
      docker_compose
      mysql-workbench
      slack
      soapui
    ];

    sessionVariables = {
      # see: https://github.com/NixOS/nixpkgs/issues/38991#issuecomment-400657551
      LOCALE_ARCHIVE_2_11 = "/usr/bin/locale/locale-archive";
      LOCALE_ARCHIVE_2_27 = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    };
  };

  xsession.profileExtra = ''
    exec > ~/.xsession-errors 2>&1
    xrandr --output eDP-1 --mode 1920x1080
    xrandr --output DP-1 --auto --left-of eDP-1
  '';
}
