{ config, lib, pkgs, ... }:

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
        type = types.listOf (types.enum [ "atom" "gpg" "home-manager" "nix-on-droid" "vscode" ]);
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
      custom.programs.atom.enable = true;
    })

  ]);

}
