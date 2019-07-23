{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.shell;

  localeGerman = "de_DE.UTF-8";
  localeEnglish = "en_US.UTF-8";

  environmentVariables = {
    LC_CTYPE = localeEnglish;
    LC_NUMERIC = localeEnglish;
    LC_TIME = localeGerman;
    LC_COLLATE = localeEnglish;
    LC_MONETARY = localeEnglish;
    LC_MESSAGES = localeEnglish;
    LC_PAPER = localeGerman;
    LC_NAME = localeEnglish;
    LC_ADDRESS = localeEnglish;
    LC_TELEPHONE = localeEnglish;
    LC_MEASUREMENT = localeGerman;
    LC_IDENTIFICATION = localeEnglish;
    LC_ALL = "";

    LANG = localeEnglish;
    LANGUAGE = localeEnglish;

    TERM = "screen-256color";

    PAGER = "${pkgs.less}/bin/less -FRX";
    EDITOR = "${pkgs.neovim}/bin/nvim";
  };
in

{

  ###### interface

  options = {

    custom.shell = {

      enable = mkEnableOption "basic shell config";

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    programs = {
      bash.sessionVariables = environmentVariables;
      zsh = {
        inherit environmentVariables;
      };
    };

  };

}
