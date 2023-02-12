{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.custom.programs.ssh;

  keysDirectory = "${config.home.homeDirectory}/.ssh/keys";
in

{

  ###### interface

  options = {

    custom.programs.ssh = {

      enable = mkEnableOption "ssh config";

      cleanKeysOnShellStartup = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to clean all keys in keychain on top level shell startup.
        '';
      };

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
              keychain "$key"
            fi

            if [[ $# > 1 ]]; then
              kadd "''${@:2}"
            fi
          }
        '';

        loginExtra = mkIf cfg.cleanKeysOnShellStartup ''
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

    programs = {
      keychain = {
        enable = true;
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

        includes = [ "~/.ssh/config.d/*" ];
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
