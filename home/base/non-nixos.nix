{ config, lib, pkgs, inputs, ... }:

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

      builders = mkOption {
        type = types.listOf types.string;
        default = [ ];
        description = "Nix remote builders.";
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    home = {
      packages = mkIf cfg.installNix [ config.nix.package ];
      sessionVariables.NIX_PATH = "nixpkgs=${inputs.nixpkgs}";
    };

    nix = {
      package = pkgs.nixVersions.nix_2_13;
      registry = {
        nixpkgs.flake = inputs.nixpkgs;
        nix-config.flake = inputs.self;
      };
    };

    programs.zsh.envExtra = mkAfter ''
      hash -f
    '';

    targets.genericLinux.enable = true;

    xdg.configFile."nix/nix.conf".text = ''
      substituters = ${concatStringsSep " " substituters}
      trusted-public-keys = ${concatStringsSep " " trustedPublicKeys}
      trusted-users = ${config.home.username}
      experimental-features = nix-command flakes
      log-lines = 30
      builders = ${concatStringsSep ";" cfg.builders}
      ${optionalString (cfg.builders != []) ''
        builders-use-substitutes = true
      ''}
      flake-registry = ""
    '';

  };

}
