{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.development.direnv;

  # FIXME: fetch names of devShells dynamically
  devShells = [ "jdk8" "jdk11" "jdk15" "jdk17" "php74" "php80" "php81" ];
in

{
  ###### interface

  options = {

    custom.development.direnv.enable = mkEnableOption "direnv setup";

  };


  ###### implementation

  config = mkIf cfg.enable {

    home.packages = [
      /* Disable direnv-init for now because lorri-init is still preferred and should not be confused
        (config.lib.custom.mkScript
        "direnv-init"
        ./direnv-init.sh
        [ pkgs.direnv ]
        { }
        )

        (config.lib.custom.mkZshCompletion
        "direnv-init"
        ./direnv-init-completion.zsh
        { inherit devShells; }
        )
      */

      (config.lib.custom.mkScript
        "lorri-init"
        ./lorri-init.sh
        # FIXME: change lorri to not need any further runtime dependencies
        (with pkgs; [ direnv gnutar gzip lorri nix ])
        {
          nixConfigDir = "${config.home.homeDirectory}/.nix-config";
        }
      )

      (config.lib.custom.mkZshCompletion
        "lorri-init"
        ./lorri-init-completion.zsh
        { inherit devShells; }
      )
    ];

    programs = {
      direnv = {
        enable = true;

        nix-direnv.enable = true;
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

    services.lorri.enable = true;

  };

}
