{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.development.direnv;
in

{
  ###### interface

  options = {

    custom.development.direnv.enable = mkEnableOption "direnv setup";

  };


  ###### implementation

  config = mkIf cfg.enable {

    home.packages = [
      (config.lib.custom.mkScript
        "direnv-init"
        ./direnv-init.sh
        [ pkgs.direnv ]
        { }
      )

      (config.lib.custom.mkZshCompletion
        "direnv-init"
        ./direnv-init-completion.zsh
        {
          # FIXME: fetch names of devShells dynamically
          devShells = [ "jdk8" "jdk11" "jdk15" "jdk17" ];
        }
      )
    ];

    programs = {
      direnv = {
        enable = true;

        nix-direnv = {
          enable = true;
          enableFlakes = true;
        };
      };

      zsh.initExtraBeforeCompInit = ''
        # is set in nix-shell
        if [[ ! -z "$buildInputs" ]]; then
          for buildInput in "''${(ps: :)buildInputs}"; do
            directories=(
              $buildInput/share/zsh/site-functions
              $buildInput/share/zsh/$ZSH_VERSION/functions
              $buildInput/share/zsh/vendor-completions
            )

            for directory in $directories; do
              if [[ -d "$directory" ]]; then
                fpath+=("$directory")
              fi
            done
          done
        fi
      '';
    };

  };

}
