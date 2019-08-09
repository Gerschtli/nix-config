{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.misc.non-nixos;

  nixPath = "/nix/var/nix/profiles/per-user/${config.home.username}/channels";
in

{

  ###### interface

  options = {

    custom.misc.non-nixos.enable = mkEnableOption "config for non NixOS systems";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom = {
      misc = {
        dotfiles = {
          enable = true;
          modules = [ "home-manager" ];
        };

        nix-channels = {
          enable = true;
          nixpkgs = true;
        };
      };

      programs.shell.envExtra = mkBefore ''
        source "${pkgs.nix}/etc/profile.d/nix.sh"

        export NIX_PATH="''${NIX_PATH:+$NIX_PATH:}${nixPath}"
        export NIX_PROFILES="/etc/profiles/per-user/$USER /run/current-system/sw /nix/var/nix/profiles/default $HOME/.nix-profile"
      '';
    };

    home.packages = [ pkgs.nix ];

    programs.zsh.envExtra = mkAfter ''
      hash -f
    '';

    systemd.user.sessionVariables = {
      NIX_PATH = "\${NIX_PATH:+$NIX_PATH:}${nixPath}";
    };

  };

}
