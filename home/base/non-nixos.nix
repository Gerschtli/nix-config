{ config, lib, pkgs, inputs, ... }@configArgs:

let
  inherit (lib)
    concatStringsSep
    mkAfter
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    optionals
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
        type = types.listOf types.str;
        default = [ ];
        description = "Nix remote builders.";
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.misc.darwin-keyboard-layout.enable = config.custom.base.general.darwin;

    home = {
      packages = optionals cfg.installNix [ config.nix.package ]
        ++ optionals config.custom.base.general.darwin [ pkgs.bashInteractive pkgs.coreutils pkgs.procps ];

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

    programs.zsh.envExtra = mkMerge [
      (mkAfter ''
        hash -f
      '')

      (mkIf config.custom.base.general.darwin ''
        eval "$(/opt/homebrew/bin/brew shellenv)"
      '')
    ];

    targets.genericLinux.enable = !config.custom.base.general.darwin;

  };

}
