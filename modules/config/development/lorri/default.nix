{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.development.lorri;

  nixProfiles = "nix/profiles";
  nixProfilesDir = "${config.xdg.configHome}/${nixProfiles}";
in

{
  ###### interface

  options = {

    custom.development.lorri.enable = mkEnableOption "lorri setup";

  };


  ###### implementation

  config = mkIf cfg.enable {

    home.packages = [
      (config.lib.custom.buildScript
        "lorri-init"
        ./lorri-init.sh
        [ pkgs.direnv pkgs.lorri pkgs.nix ]
        { inherit nixProfilesDir; }
      )

      (config.lib.custom.buildZshCompletion
        "lorri-init"
        ./lorri-init-completion.zsh
        { inherit nixProfilesDir; }
      )
    ];

    programs = {
      direnv = {
        enable = true;
        stdlib = ''
          use_flake() {
            watch_file flake.nix
            watch_file flake.lock
            mkdir --parents "$(direnv_layout_dir)"
            eval "$(nix print-dev-env --profile "$(direnv_layout_dir)/flake-profile")"
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

    xdg.configFile."${nixProfiles}" = {
      source = config.lib.custom.path.files + "/nix/profiles";
      recursive = true;
    };

  };

}
