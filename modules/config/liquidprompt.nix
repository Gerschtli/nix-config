{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.liquidprompt;

  # TODO: add in nixpkgs
  liquidprompt = pkgs.stdenv.mkDerivation {
    name = "liquidprompt";

    src = pkgs.fetchFromGitHub {
      owner = "nojhan";
      repo = "liquidprompt";
      rev = "eda83efe4e0044f880370ed5e92aa7e3fdbef971";
      sha256 = "1p7ah3x850ajpq07xvxxd7fx2i67cf0n71ww085g32k9fwij4rd4";
    };

    installPhase = ''
      mkdir -p $out/share/liquidprompt

      install -m 0644 liquidprompt $out/share/liquidprompt
      install -m 0644 liquidprompt.plugin.zsh $out/share/liquidprompt
    '';
  };

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
    LP_ENABLE_JOBS = 1;
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
  };
in

{

  ###### interface

  options = {

    custom.liquidprompt.enable = mkEnableOption "liquidprompt config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    # TODO: add as module to home-manager
    programs = {
      bash.initExtra = ''
        source ${liquidprompt}/share/liquidprompt/liquidprompt
      '';

      zsh.plugins = [
        {
          name = "liquidprompt";
          src = "${liquidprompt}/share/liquidprompt";
        }
      ];
    };

    xdg.configFile."liquidpromptrc".text = ''
      ${concatMapStringsSep "\n" (key: "${key}=${toString liquidpromptConfig.${key}}") (attrNames liquidpromptConfig)}

      # PS1 Modifications

      LP_PS1_SHELL_SYMBOL="\$"
      if [[ -n "''${BASH_VERSION-}" ]]; then
          LP_PS1_SHELL_SYMBOL="B"
      fi

      LP_PS1_POSTFIX=$'\n'"''${BOLD_GREEN}''${LP_PS1_SHELL_SYMBOL}>''${NO_COL} "
    '';

  };

}
