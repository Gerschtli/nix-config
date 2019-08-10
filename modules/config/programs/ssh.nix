{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.programs.ssh;

  customLib = import ../../lib args;

  directorySource = toString ../../secrets/ssh/modules;
  directoryDestination = "${config.home.homeDirectory}/.ssh/modules";
in

{

  ###### interface

  options = {

    custom.programs.ssh = {

      enable = mkEnableOption "ssh config";

      enableKeychain = mkEnableOption "keychain setup" // {
        default = true;
      };

      controlMaster = mkOption {
        type = types.enum ["yes" "no" "ask" "auto" "autoask"];
        default = "auto";
        description = ''
          Configure sharing of multiple sessions over a single network connection.
        '';
      };

      modules = mkOption {
        type = types.listOf (types.enum [ "private" "pveu" "vcs" ]);
        default = [];
        description = "SSH modules to enable.";
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.shell = {
      initExtra = mkMerge [
        ''
          keygen() {
            if [[ -z "$1" ]]; then
              echo "Enter path  as argument!"
            else
              ssh-keygen -t rsa -b 4096 -f "$1"
            fi
          }
        ''

        (mkIf cfg.enableKeychain ''
          kadd() {
            local key="$(find "${directoryDestination}" -type f -name "id_rsa.$1" | head -n 1)"

            if [[ ! -r "$key" ]]; then
              echo "ssh key not found: $key"
            else
              keychain "$key"
            fi

            if [[ $# > 1 ]]; then
              kadd "''${@:2}"
            fi
          }
        '')
      ];

      loginExtra = mkIf cfg.enableKeychain ''
        # remove existing keys
        if [[ $SHLVL == 1 ]]; then
          keychain --clear --quiet
        fi
      '';
    };

    home = {
      activationExtra = ''
        if [[ ! -d "${directorySource}" || ! -r "${directorySource}" ]]; then
          >&2 echo "${directorySource} has to be a readable directory for user '${config.home.username}'"
          exit 1
        fi

        $DRY_RUN_CMD rm $VERBOSE_ARG --recursive --force "${directoryDestination}"
        $DRY_RUN_CMD mkdir --parents "${directoryDestination}"

        $DRY_RUN_CMD pushd "${directorySource}" > /dev/null

        # use xargs so that activation fails if one cp/chmod command fails
        ${concatMapStringsSep "\n" (module: ''
          $DRY_RUN_CMD find . -type f -path "./${module}/keys/*" -print0 | \
            xargs -0 -n 1 -I % cp $VERBOSE_ARG --archive --parents "%" "${directoryDestination}"
        '') cfg.modules}

        $DRY_RUN_CMD find "${directoryDestination}" -type f -path "*/keys/*" -print0 | \
          xargs -0 -n 1 -I % chmod 0600 "%"

        $DRY_RUN_CMD popd > /dev/null
      '';

      packages = mkIf cfg.enableKeychain [
        (pkgs.writeTextFile {
          name = "_kadd";
          destination = "/share/zsh/site-functions/_kadd";
          text = ''
            #compdef kadd

            LIST=()

            for module in "${directoryDestination}/"*; do
              prefix="$module/keys/id_rsa."
              suffix=".pub"

              for keyfile in "$prefix"*"$suffix"; do
                  tmp="''${keyfile#$prefix}"
                  LIST=("''${tmp//$suffix}" "$LIST")
              done
            done

            _arguments "*:ssh keys:($LIST)"
          '';
        })
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

        matchBlocks = mkMerge (
          map
            (module: (
              import "${directorySource}/${module}" {
                inherit lib;
                path = "${directoryDestination}/${module}";
              }
            ).matchBlocks)
            cfg.modules
        );
      };
    };

  };

}
