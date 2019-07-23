{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.bash;
in

{

  ###### interface

  options = {

    custom.bash.enable = mkEnableOption "bash config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.shell.enable = true;

    programs.bash = {
      enable = true;
      historySize = 1000;
      historyFileSize = 2000;
      historyControl = [ "ignorespace" "ignoredups" ];

      initExtra = ''
        shell-reload() {
            [[ -r "$HOME/.bash_profile" ]] && source "$HOME/.bash_profile"
        }
      '';
    };

  };

}
