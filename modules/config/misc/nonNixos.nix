{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.misc.nonNixos;
in

{

  ###### interface

  options = {

    custom.misc.nonNixos.enable = mkEnableOption "config for non NixOS systems";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom = {
      misc.dotfiles = {
        enable = true;
        modules = [ "home-manager" ];
      };

      programs.shell.envExtra = mkBefore ''
        source "${pkgs.nix}/etc/profile.d/nix.sh"
      '';
    };

    programs.zsh.envExtra = mkAfter ''
      hash -f
    '';

  };

}
