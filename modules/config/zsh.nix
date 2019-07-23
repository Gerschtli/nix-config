{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.zsh;
in

{

  ###### interface

  options = {

    custom.zsh.enable = mkEnableOption "zsh config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.shell.enable = true;

    programs.zsh = {
      enable = true;
      autocd = true;
      defaultKeymap = "viins";
      dotDir = ".config/zsh";
      enableAutosuggestions = true;

      plugins = [
        {
          name = "zsh-completions";
          src = "${pkgs.zsh-completions}/share/zsh/site-functions";
        }
      ];
    };

  };

}
