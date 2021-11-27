{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.base.non-nixos;

  substituters = [
    "https://cache.nixos.org"
    "https://gerschtli.cachix.org"
    "https://nix-on-droid.cachix.org"
  ];
  trustedPublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "gerschtli.cachix.org-1:dWJ/WiIA3W2tTornS/2agax+OI0yQF8ZA2SFjU56vZ0="
    "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU="
  ];
in

{

  ###### interface

  options = {

    custom.base.non-nixos = {
      enable = mkEnableOption "config for non NixOS systems";

      installNix = mkEnableOption "nix installation" // { default = true; };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.misc.dotfiles = {
      enable = true;
      modules = [ "home-manager" ];
    };

    home.packages = mkIf cfg.installNix [ pkgs.nixFlakes ];

    programs.zsh.envExtra = mkAfter ''
      hash -f
    '';

    targets.genericLinux.enable = true;

    xdg.configFile."nix/nix.conf".text = ''
      substituters = ${concatStringsSep " " substituters}
      trusted-public-keys = ${concatStringsSep " " trustedPublicKeys}
      trusted-users = root tobias
      experimental-features = nix-command flakes
    '';

  };

}
