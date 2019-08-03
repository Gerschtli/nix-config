{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.ssh;

  customLib = import ../lib args;

  directorySource = toString ../secrets/ssh/modules;
  directoryDestination = "${config.home.homeDirectory}/.ssh/modules";

  modules = customLib.getDirectoryList directorySource;
in

{

  ###### interface

  options = {

    custom.ssh.enable = mkEnableOption "ssh config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.shell = {
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
            keychain "$key"
          fi

          if [[ $# > 1 ]]; then
            kadd "''${@:2}"
          fi
        }
      '';

      profileExtra = ''
        # remove existing keys
        if [[ $SHLVL == 1 ]]; then
          keychain --clear --quiet
        fi
      '';
    };

    home.packages = [
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

    programs = {
      keychain = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        agents = [ "ssh" ];
      };

      ssh = {
        enable = true;

        compression = true;
        serverAliveInterval = 30;
        hashKnownHosts = true;
        controlMaster = "auto";
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
              import module {
                inherit lib;
                path = "${directoryDestination}/${baseNameOf module}";
              }
            ).matchBlocks)
            modules
        );
      };
    };

    systemd.user.services.install-ssh-keys = {
      Unit = {
        Description = "Install ssh keys";
      };

      Install = {
        WantedBy = [ "multi-user.target" ];
      };

      Service = {
        Type = "oneshot";
        RemainAfterExit = "yes";

        ExecStart = "${pkgs.writeScript "install-ssh-keys.sh" ''
          #!${pkgs.runtimeShell} -e

          if [[ ! -d "${directorySource}" || ! -r "${directorySource}" ]]; then
            >&2 echo "${directorySource} has to be a readable directory for user '${config.home.username}'"
            exit 1
          fi

          rm --verbose --recursive --force "${directoryDestination}"
          mkdir --parents "${directoryDestination}"

          cd "${directorySource}"
          find . -type f -path "*/keys/*" -exec cp --archive --verbose --parents "{}" "${directoryDestination}" \;
        ''}";
      };
    };

  };

}
