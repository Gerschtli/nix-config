{ config, lib, pkgs, homeModules, inputs, rootPath, ... }:

with lib;

let
  cfg = config.custom.base.general;
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

    boot.cleanTmpDir = true;

    console.keyMap = "de";

    custom = {
      cachix-agent.enable = true;

      system.firewall.enable = true;
    };

    environment = {
      defaultPackages = [ ];
      shellAliases = mkForce { };
    };

    home-manager = {
      backupFileExtension = "hm-bak";
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs rootPath; };
      sharedModules = homeModules;

      users = {
        root = import "${rootPath}/hosts/${cfg.hostname}/home-root.nix";
        tobias = import "${rootPath}/hosts/${cfg.hostname}/home-tobias.nix";
      };
    };

    networking = {
      hostName = cfg.hostname;
      usePredictableInterfaceNames = false;
    };

    nix = {
      settings = {
        trusted-substituters = [
          "https://cache.nixos.org"
          "https://gerschtli.cachix.org"
          "https://nix-on-droid.cachix.org"
        ];
        trusted-public-keys = mkForce [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "gerschtli.cachix.org-1:dWJ/WiIA3W2tTornS/2agax+OI0yQF8ZA2SFjU56vZ0="
          "nix-on-droid.cachix.org-1:56snoMJTXmDRC1Ei24CmKoUqvHJ9XCp+nidK7qkMQrU="
        ];
        trusted-users = [ "root" "tobias" ];
      };

      registry = {
        nixpkgs.flake = inputs.nixpkgs;
        nix-config.flake = inputs.self;
      };
      nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

      extraOptions = ''
        experimental-features = nix-command flakes
        log-lines = 30
      '';
    };

    programs.zsh = {
      enable = true;
      enableGlobalCompInit = false;
      promptInit = "";
    };

    system = {
      configurationRevision = inputs.self.rev or "dirty";
      stateVersion = "22.11";
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
