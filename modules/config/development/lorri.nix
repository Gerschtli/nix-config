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
      (pkgs.writeScriptBin "lorri-init" ''
        #!${pkgs.runtimeShell} -e

        shell_name="$1"
        force="$2"
        shell_path="${nixProfilesDir}/''${shell_name}.nix"

        _log() {
          echo ">> $@"
        }

        if [[ ( ! -f shell.nix || "$force" == "--force" ) && -f "$shell_path" ]]; then
          _log "Link shell.nix"
          ln -snfv "$shell_path" shell.nix
        fi

        _log "Run lorri init"
        ${pkgs.lorri}/bin/lorri init

        _log "Allow .envrc"
        ${pkgs.direnv}/bin/direnv allow

        _log "Run lorri watch --once"
        ${pkgs.lorri}/bin/lorri watch --once
      '')

      (pkgs.writeTextFile {
        name = "_lorri-init";
        destination = "/share/zsh/site-functions/_lorri-init";
        text = ''
          #compdef lorri-init

          list=()

          prefix="${nixProfilesDir}/"
          suffix=".nix"

          for file in "$prefix"*"$suffix"; do
            tmp="''${file#$prefix}"
            list=("''${tmp//$suffix}" "$list")
          done

          _arguments \
            "1:nix-shell profiles:($list)" \
            "*:options:(--force)"
        '';
      })
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
