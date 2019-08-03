{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom = {
    # desktop / pass
    dotfiles = {
      enable = true;
      modules = [ "atom" ];
    };
    pass = {
      enable = true;
      browserpass = true;
      x11Support = true;
    };

    # development
    direnv.enable = true;
    lorri.enable = true;

    # desktop
    dunst.enable = true;
    urxvt.enable = true;
    xsession.enable = true;
  };
}
