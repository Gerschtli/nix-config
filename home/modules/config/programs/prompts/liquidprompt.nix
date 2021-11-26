{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.prompts.liquidprompt;

  liquidpromptConfig = {
    LP_ENABLE_BATT = 0;
    LP_ENABLE_BZR = 0;
    LP_ENABLE_DETACHED_SESSIONS = 0;
    LP_ENABLE_FOSSIL = 0;
    LP_ENABLE_FQDN = 0;
    LP_ENABLE_GIT = 1;
    LP_ENABLE_HG = 0;
    LP_ENABLE_JOBS = 0;
    LP_ENABLE_SCLS = 0;
    LP_ENABLE_SVN = 0;
    LP_ENABLE_TEMP = 0;
    LP_ENABLE_VCS_ROOT = 1;
    LP_ENABLE_VIRTUALENV = 0;
    LP_HOSTNAME_ALWAYS = 1;
    LP_PATH_LENGTH = 50;
  };
in

{

  ###### interface

  options = {

    custom.programs.prompts.liquidprompt = {

      enable = mkEnableOption "liquidprompt config";

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

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
