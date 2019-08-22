{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.development.lorri;

  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
    inherit pkgs;
    repoOverrides = {
      gerschtli = import (builtins.fetchTarball "https://github.com/Gerschtli/nur-packages/archive/master.tar.gz") { inherit pkgs; };
    };
  };
in

{
  imports = [
    nur.repos.gerschtli.hmModules.services.lorri
  ];


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

        if [[ ! -f shell.nix || "$force" == "--force" ]]; then
          shell_content="import \"${config.xdg.configHome}/nix/profiles/''${shell_name}.nix\""

          echo -e "Write shell.nix\n\t''${shell_content}\n"
          echo "$shell_content" > shell.nix
        fi

        env_content="eval \"\$(lorri direnv)\""
        echo -e "Write .envrc\n\t''${env_content}\n"
        echo "$env_content" > .envrc

        echo -e "Allow .envrc\n"
        ${pkgs.direnv}/bin/direnv allow

        echo -e "Run lorri watch"
        lorri watch
      '')

      (pkgs.writeTextFile {
        name = "_lorri-init";
        destination = "/share/zsh/site-functions/_lorri-init";
        text = ''
          #compdef lorri-init

          list=()

          prefix="${config.xdg.configHome}/nix/profiles/"
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
        enableBashIntegration = true;
        enableZshIntegration = true;
      };

      zsh.initExtraBeforeCompInit = ''
        # is set in nix.shell
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

    xdg.configFile."nix/profiles" = {
      source = ../../files/nix/profiles;
      recursive = true;
    };

  };

}
