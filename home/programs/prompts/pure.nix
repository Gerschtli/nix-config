{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.prompts.pure;
in

{

  ###### interface

  options = {

    custom.programs.prompts.pure.enable = mkEnableOption "pure prompt";

  };


  ###### implementation

  config = mkIf cfg.enable {

    home.sessionVariables.PURE_GIT_PULL = 0;

    programs.zsh = {
      initExtra = ''
        autoload -U promptinit; promptinit
        prompt pure
      '';

      plugins = [
        {
          name = "pure";
          src = "${pkgs.pure-prompt}/share/zsh/site-functions";
        }
      ];
    };

  };

}
