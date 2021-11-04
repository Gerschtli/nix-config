{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.ssh;

  directorySource = "${config.lib.custom.path.secrets}/ssh/modules";
  directoryDestination = "${config.home.homeDirectory}/.ssh/modules";
in

{

  ###### interface

  options = {

    custom.programs.ssh = {

      enable = mkEnableOption "ssh config";

      enableKeychain = mkEnableOption "keychain setup" // { default = true; };

      controlMaster = mkOption {
        type = types.enum [ "yes" "no" "ask" "auto" "autoask" ];
        default = "auto";
        description = ''
          Configure sharing of multiple sessions over a single network connection.
        '';
      };

      modules = mkOption {
        type = types.listOf (types.enum [ "private" "vcs" ]);
        default = [ ];
        description = "SSH modules to enable.";
      };

      useGithub = mkOption {
        type = types.enum [ "vcs" ];
        default = "vcs";
        description = "SSH module to use for github.com host.";
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.shell = {
      initExtra = ''
        keygen() {
          if [[ -z "$1" ]]; then
            echo "Enter path  as argument!"
          else
            ssh-keygen -t rsa -b 4096 -f "$1"
          fi
        }

        kadd() {
          local key="$(find "${directoryDestination}" -type f -name "id_rsa.$1" | head -n 1)"

          if [[ ! -r "$key" ]]; then
            echo "ssh key not found: $key"
          else
            ${
              if cfg.enableKeychain
              then ''
                keychain "$key"
              ''
              else ''
                if ! ssh-add -l | grep " $key " > /dev/null 2>&1; then
                  ssh-add "$key"
                fi
              ''
            }
          fi

          if [[ $# > 1 ]]; then
            kadd "''${@:2}"
          fi
        }
      '';

      loginExtra = mkIf cfg.enableKeychain ''
        # remove existing keys
        if [[ $SHLVL == 1 ]]; then
          keychain --clear --quiet
        fi
      '';
    };

    home = {
      activation.copySshKeys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [[ ! -d "${directorySource}" || ! -r "${directorySource}" ]]; then
          >&2 echo "${directorySource} has to be a readable directory for user '${config.home.username}'"
          exit 1
        fi

        $DRY_RUN_CMD rm $VERBOSE_ARG --recursive --force "${directoryDestination}"
        $DRY_RUN_CMD mkdir --parents "${directoryDestination}"

        $DRY_RUN_CMD pushd "${directorySource}" > /dev/null

        # use xargs so that activation fails if one cp/chmod command fails
        ${concatMapStringsSep "\n" (module: ''
          $DRY_RUN_CMD find . -type f -path "./${module}/keys/*" -print0 |
            xargs -0 -I % cp $VERBOSE_ARG --archive --parents "%" "${directoryDestination}"
        '') cfg.modules}

        $DRY_RUN_CMD find "${directoryDestination}" -type f -path "*/keys/*" -print0 |
          xargs -0 -I % chmod 0600 "%"

        $DRY_RUN_CMD popd > /dev/null
      '';

      packages = [
        pkgs.openssh

        (config.lib.custom.mkZshCompletion
          "kadd"
          ./kadd-completion.zsh
          { inherit directoryDestination; }
        )
      ];
    };

    programs = {
      keychain = {
        enable = cfg.enableKeychain;
        enableBashIntegration = true;
        enableZshIntegration = true;
        agents = [ "ssh" ];
        keys = [ ];
      };

      ssh = {
        inherit (cfg) controlMaster;

        enable = true;

        compression = true;
        serverAliveInterval = 30;
        hashKnownHosts = true;
        controlPath = "~/.ssh/socket-%r@%h-%p";
        controlPersist = "10m";

        extraConfig = ''
          CheckHostIP yes
          ConnectTimeout 60
          EnableSSHKeysign yes
          ExitOnForwardFailure yes
          ForwardX11Trusted yes
          IdentitiesOnly yes
          NoHostAuthenticationForLocalhost yes
          Protocol 2
          PubKeyAuthentication yes
          SendEnv LANG LC_*
          ServerAliveCountMax 30
        '';

        matchBlocks = listToAttrs
          (concatMap
            (module:
              let
                sshModule = import "${directorySource}/${module}" {
                  inherit lib;
                  path = "${directoryDestination}/${module}";
                  useGithub = cfg.useGithub == module;
                };
              in
              map
                (matchBlock: nameValuePair matchBlock.host matchBlock)
                sshModule.matchBlocks
            )
            cfg.modules
          );
      };
    };

  };

}
