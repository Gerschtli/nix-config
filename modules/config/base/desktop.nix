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

      private = mkEnableOption "private desktop config";
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
        pass = mkIf cfg.private {
          enable = true;
          browserpass = true;
        };

        ssh.modules = [ "private" ];
      };
    };

    home.packages = with pkgs; [
      gimp
      google-chrome
      jetbrains.idea-ultimate
      libreoffice
      nomacs
      pdftk
      postman
      qpdfview
      spotify
    ] ++ (optionals cfg.private [
      audacity
      musescore
      thunderbird
    ]);

    programs.gh = {
      enable = true;
      gitProtocol = "ssh";
    };

    systemd.user.startServices = true;

    xdg.mimeApps = {
      enable = true;

      defaultApplications = {
        "application/pdf" = "qpdfview.desktop";

        "image/jpeg" = "nomacs.desktop";
        "image/png" = "nomacs.desktop";

        "message/rfc822" = "thunderbird.desktop";
        "x-scheme-handler/mailto" = "thunderbird.desktop";

        "text/html" = "google-chrome.desktop";
        "x-scheme-handler/http" = "google-chrome.desktop";
        "x-scheme-handler/https" = "google-chrome.desktop";
        "x-scheme-handler/about" = "google-chrome.desktop";
        "x-scheme-handler/unknown" = "google-chrome.desktop";
      };
    };

  };

}
