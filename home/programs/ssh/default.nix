{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.programs.ssh;

  keysDirectory = "${config.home.homeDirectory}/.ssh/keys";
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
        type = types.listOf (types.enum [ "private" "sedo" "vcs" ]);
        default = [ ];
        description = "SSH modules to enable.";
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom = {
      misc.homeage.secrets = map (value: "ssh-${value}") cfg.modules;

      programs.shell = {
        initExtra = ''
          keygen() {
            if [[ -z "$1" ]]; then
              echo "Enter path  as argument!"
            else
              ssh-keygen -t rsa -b 4096 -f "$1"
            fi
          }

          kadd() {
            local key="${keysDirectory}/id_rsa.$1"

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
    };

    home.packages = [
      pkgs.openssh

      (config.lib.custom.mkZshCompletion
        "kadd"
        ./kadd-completion.zsh
        { inherit keysDirectory; }
      )
    ];

    # FIXME: remove in 21.11
    home.file.".ssh/config".text = mkBefore ''
      Include ~/.ssh/config.d/*
    '';

    programs = {
      keychain = {
        enable = cfg.enableKeychain;
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

        # FIXME: use in 21.11
        #includes = [ "~/.ssh/config.d/*" ];
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
      };
    };

  };

}
