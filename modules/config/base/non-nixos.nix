{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.base.non-nixos;
in

{

  ###### interface

  options = {

    custom.base.non-nixos.enable = mkEnableOption "config for non NixOS systems" // {
      default = !config.lib.os.isNixOS;
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.misc = {
      dotfiles = {
        enable = true;
        modules = [ "home-manager" ];
      };

      nix-channels = {
        enable = true;
        nixpkgs = true;
      };
    };

    home.packages = [ pkgs.nix ];

    programs.zsh.envExtra = mkAfter ''
      hash -f
    '';

  };

}
