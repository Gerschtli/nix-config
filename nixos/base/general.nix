{ config, lib, pkgs, homeModules, inputs, rootPath, ... }@configArgs:

let
  inherit (lib)
    genAttrs
    mkEnableOption
    mkForce
    mkIf
    mkOption
    types
    ;

  cfg = config.custom.base.general;

  commonConfig = config.lib.custom.commonConfig configArgs;
in

{

  imports = [ inputs.home-manager.nixosModules.home-manager ];


  ###### interface

  options = {

    custom.base.general = {
      enable = mkEnableOption "basic config" // { default = true; };

      hostname = mkOption {
        type = types.enum [ "argon" "krypton" "neon" "xenon" ];
        description = "Host name.";
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    boot.tmp.cleanOnBoot = true;

    console.keyMap = "de";

    custom.system.firewall.enable = true;

    environment = {
      defaultPackages = [ ];
      shellAliases = mkForce { };
    };

    home-manager = {
      inherit (commonConfig.homeManager.baseConfig)
        backupFileExtension
        extraSpecialArgs
        sharedModules
        useGlobalPkgs
        useUserPackages
        ;

      users = genAttrs [ "root" "tobias" ] (commonConfig.homeManager.userConfig cfg.hostname);
    };

    i18n.supportedLocales = [
      "C.UTF-8/UTF-8"
      "de_DE.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];

    networking = {
      hostName = cfg.hostname;
      usePredictableInterfaceNames = false;
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

        trusted-users = [ "root" "tobias" ];
      };

      inherit (commonConfig.nix)
        nixPath
        package
        registry
        ;
    };

    # disabled because manually set via commonConfig.nix
    nixpkgs.flake = {
      setNixPath = false;
      setFlakeRegistry = false;
    };

    programs.zsh = {
      enable = true;
      enableGlobalCompInit = false;
      promptInit = "";
    };

    system = {
      configurationRevision = inputs.self.rev or "dirty";
      stateVersion = "24.05";
    };

    time.timeZone = "Europe/Berlin";

    users.users = {
      root.shell = pkgs.zsh;

      tobias = {
        uid = config.custom.ids.uids.tobias;
        extraGroups = [ "wheel" ];
        isNormalUser = true;
        shell = pkgs.zsh;
      };
    };

  };

}
