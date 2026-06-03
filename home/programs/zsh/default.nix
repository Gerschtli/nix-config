{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    readFile
    ;

  cfg = config.custom.programs.zsh;
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
      enable = true;
      autocd = true;
      defaultKeymap = "viins";
      autosuggestion.enable = true;

      initContent = ''
        available sudo && alias sudo='nocorrect sudo '

        alias -g C="| ${if config.custom.base.general.darwin then "pbcopy" else "${pkgs.xclip}/bin/xclip -selection clipboard"}"
        alias -g G="| grep"
        alias -g P="| $PAGER"
        alias -g IX="| ${pkgs.curl}/bin/curl -F 'f:1=<-' ix.io"

        ${readFile ./completion.zsh}

        ${readFile ./keybindings.zsh}
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
