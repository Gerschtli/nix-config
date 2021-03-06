{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.zsh;

  dotDir = ".config/zsh";
in

{

  ###### interface

  options = {

    custom.programs.zsh.enable = mkEnableOption "zsh config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.shell.enable = true;

    programs.zsh = {
      inherit dotDir;

      enable = true;
      autocd = true;
      defaultKeymap = "viins";
      enableAutosuggestions = true;
      history.path = "${config.xdg.configHome}/zsh/.zsh_history";

      initExtra = ''
        available sudo && alias sudo='nocorrect sudo '

        alias -g C="| ${pkgs.xclip}/bin/xclip -selection clipboard"
        alias -g G="| grep"
        alias -g P="| $PAGER"

        ${builtins.readFile ./completion.zsh}
        ${optionalString config.custom.misc.work.enable ''
          WORK_DIRECTORY="${config.custom.misc.work.directory}"
        ''}
        ${builtins.readFile ./directory-hash.zsh}
        unset WORK_DIRECTORY
        ${builtins.readFile ./keybindings.zsh}
      '';

      plugins = [
        {
          name = "zsh-completions";
          src = "${pkgs.zsh-completions}/share/zsh/site-functions";
        }
      ];
    };

  };

}
