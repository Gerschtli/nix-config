{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.development.direnv;

  # FIXME: fetch names of devShells dynamically
  devShells = [ "jdk8" "jdk11" "jdk15" "jdk17" "php74" "php80" ];
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
        { inherit devShells; }
      )

      (config.lib.custom.mkScript
        "lorri-init"
        ./lorri-init.sh
        # FIXME: change lorri do not need any further runtime dependencies
        (with pkgs; [ direnv gnutar gzip lorri nix_2_4 ])
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

    services.lorri.enable = true;

    # FIXME: add used nix package to home-manager module
    # FIXME: change lorri do not need any further runtime dependencies
    systemd.user.services.lorri.Service.Environment =
      let
        path = with pkgs; makeBinPath [ nix_2_4 gitMinimal gnutar gzip ];
      in
      mkForce [ "PATH=${path}" ];

  };

}
