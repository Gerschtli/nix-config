{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.prompts.pure;

  # TODO: add in nixpkgs
  pure = pkgs.stdenv.mkDerivation {
    name = "pure";

    src = pkgs.fetchFromGitHub {
      owner = "sindresorhus";
      repo = "pure";
      rev = "v1.10.3";
      sha256 = "0zjgnlw01ri0brx108n6miw4y0cxd6al1bh28m8v8ygshm94p1zx";
    };

    installPhase = ''
      mkdir -p $out/share/pure

      install -m 0644 pure.zsh $out/share/pure/prompt_pure_setup
      install -m 0644 async.zsh $out/share/pure/async
    '';
  };
in

{

  ###### interface

  options = {

    custom.programs.prompts.pure.enable = mkEnableOption "pure prompt";

  };


  ###### implementation

  config = mkIf cfg.enable {

    # TODO: add as module to home-manager
    programs.zsh = {
      initExtra = ''
        autoload -U promptinit; promptinit
        prompt pure
      '';

      plugins = [
        {
          name = "pure";
          src = "${pure}/share/pure";
        }
      ];
    };

  };

}
