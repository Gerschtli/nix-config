{ config, lib, pkgs, inputs, ... }@configArgs:

let
  inherit (lib)
    concatStringsSep
    mkAfter
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.custom.base.non-nixos;

  commonConfig = config.lib.custom.commonConfig configArgs;
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
      sessionVariables.NIX_PATH = concatStringsSep ":" commonConfig.nix.nixPath;
    };

    nix = {
      settings = {
        inherit (commonConfig.nix.settings)
          experimental-features
          flake-registry
          log-lines
          substituters
          trusted-public-keys
          ;

        builders = concatStringsSep ";" cfg.builders;
        builders-use-substitutes = mkIf (cfg.builders != [ ]) true;
        trusted-users = [ config.home.username ];
      };

      inherit (commonConfig.nix)
        package
        registry
        ;
    };

    programs.zsh.envExtra = mkAfter ''
      hash -f
    '';

    targets.genericLinux.enable = true;

  };

}
