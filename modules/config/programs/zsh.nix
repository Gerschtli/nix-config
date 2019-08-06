{ config, lib, pkgs, ... } @ args:

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

      initExtra = ''
        available sudo && alias sudo='nocorrect sudo '

        alias -g C="| ${pkgs.xclip}/bin/xclip -selection clipboard"
        alias -g G="| grep"
        alias -g P="| $PAGER"

        ${builtins.readFile ../../files/zsh/completion.zsh}
        ${builtins.readFile ../../files/zsh/directory-hash.zsh}
        ${builtins.readFile ../../files/zsh/keybindings.zsh}
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
