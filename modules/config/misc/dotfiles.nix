{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.misc.dotfiles;
in

{

  ###### interface

  options = {

    custom.misc.dotfiles = {
      enable = mkEnableOption "dotfiles config";

      modules = mkOption {
        type = types.listOf (types.enum [ "atom" "gpg" "home-manager" "i3" "nix-on-droid" "sublime" "vscode" ]);
        default = [];
        description = ''
          List of dotfiles modules to enable.
        '';
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable (mkMerge [

    {
      home.file.".localrc".text = ''
        MODULES=(${concatStringsSep " " cfg.modules})
      '';
    }

    (mkIf (builtins.elem "atom" cfg.modules) {
      home.packages = [ pkgs.atom ];
    })

    (mkIf (builtins.elem "gpg" cfg.modules) {
      custom.programs.shell.loginExtra = ''
        # remove existing keys
        if [[ $SHLVL -eq 1 ]]; then
          ${pkgs.procps}/bin/pkill -SIGHUP gpg-agent
        fi
      '';

      home.packages = [ pkgs.gnupg ];
    })

  ]);

}
