{ config, lib, pkgs, ... }:
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

      private = mkEnableOption "private desktop config";
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom = {
      development.direnv.enable = true;

      programs = {
        atom.enable = true;
        idea-ultimate.enable = true;

        pass = mkIf cfg.private {
          enable = true;
          browserpass = true;
        };

        ssh.modules = [ "private" ];
        tmux.urlview = true;
      };
    };

    home.packages = with pkgs; [
      gh
      gimp
      google-chrome
      libreoffice
      nomacs
      pdftk
      postman
      qpdfview
      spotify
      sshfs
    ] ++ (optionals cfg.private [
      audacity
      musescore
      thunderbird
    ]);

  };

}
