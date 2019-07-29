{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.zsh;

  dotDir = ".config/zsh";
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

        shell-reload() {
          [[ -r "$HOME/${dotDir}/.zshenv" ]]   && source "$HOME/${dotDir}/.zshenv"
          [[ -r "$HOME/${dotDir}/.zprofile" ]] && source "$HOME/${dotDir}/.zprofile"
          [[ -r "$HOME/${dotDir}/.zshrc" ]]    && source "$HOME/${dotDir}/.zshrc"
          [[ -r "$HOME/${dotDir}/.zlogin" ]]   && source "$HOME/${dotDir}/.zlogin"
        }

        source ${../files/zsh/completion.zsh}
        source ${../files/zsh/directory-hash.zsh}
        source ${../files/zsh/keybindings.zsh}
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
