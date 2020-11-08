{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.prompts.liquidprompt;

  liquidpromptConfig = {
    LP_BATTERY_THRESHOLD = 75;
    LP_LOAD_THRESHOLD = 60;
    LP_TEMP_THRESHOLD = 60;
    LP_ENABLE_SHORTEN_PATH = 1;
    LP_PATH_LENGTH = 50;
    LP_PATH_KEEP = 2;
    LP_HOSTNAME_ALWAYS = 1;
    LP_ENABLE_FQDN = 0;
    LP_USER_ALWAYS = 1;
    LP_PERCENTS_ALWAYS = 1;
    LP_ENABLE_PERM = 1;
    LP_ENABLE_PROXY = 0;
    LP_ENABLE_JOBS = 0;
    LP_ENABLE_LOAD = 1;
    LP_ENABLE_BATT = 0;
    LP_ENABLE_SUDO = 0;
    LP_ENABLE_VCS_ROOT = 1;
    LP_ENABLE_GIT = 1;
    LP_ENABLE_SVN = 0;
    LP_ENABLE_HG = 0;
    LP_ENABLE_FOSSIL = 0;
    LP_ENABLE_BZR = 0;
    LP_ENABLE_TIME = 0;
    LP_ENABLE_RUNTIME = 0;
    LP_RUNTIME_THRESHOLD = 10;
    LP_ENABLE_VIRTUALENV = 0;
    LP_ENABLE_SCLS = 0;
    LP_ENABLE_TEMP = 0;
    LP_TIME_ANALOG = 0;
    LP_ENABLE_TITLE = 0;
    LP_ENABLE_SCREEN_TITLE = 0;
    LP_ENABLE_SSH_COLORS = 0;
    LP_DISABLED_VCS_PATH = "";
  } // cfg.config;
in

{

  ###### interface

  options = {

    custom.programs.prompts.liquidprompt = {

      enable = mkEnableOption "liquidprompt config";

      config = mkOption {
        type = types.attrsOf (types.either types.int types.str);
        default = {};
        description = "Liquidprompt config.";
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    # TODO: add as module to home-manager
    programs = {
      bash.initExtra = ''
        source ${pkgs.liquidprompt}/share/zsh/plugins/liquidprompt/liquidprompt
      '';

      zsh.plugins = [
        {
          name = "liquidprompt";
          src = "${pkgs.liquidprompt}/share/zsh/plugins/liquidprompt";
        }
      ];
    };

    xdg.configFile."liquidpromptrc".text = ''
      ${concatStringsSep "\n" (mapAttrsToList (key: value: "${key}=${toString value}") liquidpromptConfig)}

      # PS1 Modifications

      LP_PS1_SHELL_SYMBOL="\$"
      if [[ -n "''${BASH_VERSION-}" ]]; then
          LP_PS1_SHELL_SYMBOL="B"
      fi

      LP_PS1_POSTFIX=$'\n'"''${BOLD_GREEN}''${LP_PS1_SHELL_SYMBOL}>''${NO_COL} "
    '';

  };

}
