{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.development.lorri;
in

{

  ###### interface

  options = {

    custom.development.lorri.enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable lorri setup.  Installation of lorri needs to be done manually
        as described in <https://github.com/target/lorri#installing-lorri>.
      '';
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    home.packages = [
      pkgs.lorri

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

    systemd.user = {
      services.lorri = {
        Unit = {
          Description = "lorri build daemon";
          Documentation = "https://github.com/target/lorri";
          ConditionUser = "!@system";
          Requires = "lorri.socket";
          After = "lorri.socket";
          RefuseManualStart = true;
        };

        Service = {
          ExecStart = "${pkgs.lorri}/bin/lorri daemon";
          PrivateTmp = true;
          ProtectSystem = "strict";
          WorkingDirectory = "%h";
          Restart = "on-failure";
          Environment =
            let
              path = with pkgs; makeSearchPath "bin" [ nix gnutar git mercurial ];
            in
              concatStringsSep " " ([
                "PATH=${path}"
                "RUST_BACKTRACE=1"
              ] ++ optional config.custom.misc.non-nixos.enable
                ''NIX_PATH="${config.custom.misc.non-nixos.nixPath}"''
              );
        };
      };

      sockets.lorri = {
        Unit = {
          Description = "lorri build daemon";
        };

        Socket = {
          ListenStream = "%t/lorri/daemon.socket";
        };

        Install = {
          WantedBy = [ "sockets.target" ];
        };
      };
    };

    xdg.configFile."nix/profiles" = {
      source = ../../files/nix/profiles;
      recursive = true;
    };

  };

}
