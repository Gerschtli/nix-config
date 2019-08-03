{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom = {
    development = {
      direnv.enable = true;

      lorri.enable = true;
    };

    misc.dotfiles = {
      enable = true;
      modules = [ "atom" ];
    };

    programs = {
      pass = {
        enable = true;
        browserpass = true;
        x11Support = true;
      };

      ssh.modules = [ "private" ];

      urxvt.enable = true;
    };

    services.dunst.enable = true;

    xsession.enable = true;
  };
}
