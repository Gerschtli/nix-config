{ config, lib, pkgs, ... } @ args:
with lib;

let
  cfg = config.custom.base.desktop;
in

{

  ###### interface

  options = {

    custom.base.desktop = {

      enable = mkEnableOption "desktop setup";

      laptop = mkEnableOption "laptop config";

      personal = mkEnableOption "personal desktop config";

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom = {
      development.lorri.enable = true;

      misc.dotfiles = {
        enable = true;
        modules = [ "atom" ];
      };

      programs = {
        pass = mkIf cfg.personal {
          enable = true;
          browserpass = true;
          x11Support = true;
        };

        ssh.modules = [ "private" ];

        urxvt.enable = true;
      };

      services = {
        dunst.enable = true;

        dwm-status = {
          inherit (cfg) laptop;

          enable = true;
        };
      };

      xsession.enable = true;
    };

    home.packages = with pkgs; [
      gimp
      jetbrains.idea-ultimate
      libreoffice
      pdftk
      postman
      spotify
    ] ++ (optionals cfg.personal [
      audacity
      musescore
      thunderbird
    ]) ++ (optionals (cfg.personal && cfg.laptop) [
      skypeforlinux
      zoom-us
    ]);

    services = {
      network-manager-applet.enable = cfg.laptop;

      unclutter = {
        enable = true;
        timeout = 3;
      };
    };

  };

}
