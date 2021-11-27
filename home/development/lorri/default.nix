{ config, lib, pkgs, rootPath, ... }:

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
      (config.lib.custom.mkScript
        "lorri-init"
        ./lorri-init.sh
        (with pkgs; [ direnv gnutar gzip lorri nix ])
        { inherit nixProfilesDir; }
      )

      (config.lib.custom.mkZshCompletion
        "lorri-init"
        ./lorri-init-completion.zsh
        { inherit nixProfilesDir; }
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

    xdg.configFile.${nixProfiles} = {
      source = rootPath + "/files/nix/profiles";
      recursive = true;
    };

  };

}
