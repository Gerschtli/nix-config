{ config, lib, pkgs, inputs, ... }:

let
  inherit (lib)
    attrNames
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.development.direnv;

  devShells = attrNames inputs.self.devShells.${pkgs.system};
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
        "lorri-init"
        ./lorri-init.sh
        (with pkgs; [ direnv gnutar gzip lorri nix ])
        { }
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

        stdlib = ''
          # from https://github.com/direnv/direnv/wiki/Customizing-cache-location
          declare -A direnv_layout_dirs
          direnv_layout_dir() {
            echo "''${direnv_layout_dirs[$PWD]:=$(
              local hash="$(sha1sum - <<<"$PWD" | cut -c-7)"
              local path="''${PWD//[^a-zA-Z0-9]/-}"
              echo "''${XDG_CACHE_HOME:-"$HOME/.cache"}/direnv/layouts/''${hash}''${path}"
            )}"
          }
        '';
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
