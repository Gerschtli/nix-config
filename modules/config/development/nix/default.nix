{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.development.nix;

  devHomeManager = "/home/tobias/projects/home-manager";
  devNixpkgs = "/home/tobias/projects/nixpkgs";
  devNurGerschtli = "/home/tobias/projects/nur-packages";

  buildWithDiff = name: command: activeLinkPath:
    config.lib.custom.buildScript
      name
      ./build-with-diff.sh
      [ pkgs.nox ]
      {
        inherit activeLinkPath command;
        _doNotClearPath = true;
      };
in

{

  ###### interface

  options = {

    custom.development.nix = {
      home-manager.enable = mkEnableOption "home-manager aliases";
      nix-on-droid.enable = mkEnableOption "nix-on-droid aliases";
      nixos.enable = mkEnableOption "nixos aliases";
    };

  };


  ###### implementation

  config = mkMerge [

    (mkIf cfg.home-manager.enable {
      custom.programs.shell.shellAliases = {
        hm-switch = "home-manager switch -b hm-bak";
      };

      home.packages = [
        (buildWithDiff "hm-build" "home-manager" "/nix/var/nix/profiles/per-user/tobias/home-manager")
      ];
    })

    (mkIf cfg.nix-on-droid.enable {
      custom.programs.shell.shellAliases = {
        nod-switch = "nix-on-droid switch";
      };

      home.packages = [
        (buildWithDiff "nod-build" "nix-on-droid" "/nix/var/nix/profiles/nix-on-droid")
      ];
     })

    (mkIf cfg.nixos.enable {
      custom.programs.shell.shellAliases = {
        n-rebuild-dev     = "nixos-rebuild test --fast";
        n-rebuild-dev-all = "nixos-rebuild test --fast -I home-manager=${devHomeManager} -I nixpkgs=${devNixpkgs}";
        n-rebuild-dev-hm  = "nixos-rebuild test --fast -I home-manager=${devHomeManager}";
        n-rebuild-dev-ng  = "nixos-rebuild test --fast -I nur-gerschtli=${devNurGerschtli}";
        n-rebuild-dev-np  = "nixos-rebuild test --fast -I nixpkgs=${devNixpkgs}";
        n-rebuild-switch  = "nixos-rebuild switch";
        n-rebuild-test    = "nixos-rebuild test";
      };

      home.packages = [
        (buildWithDiff "n-rebuild-build" "nixos-rebuild" "/run/current-system")
      ];
     })

  ];

}
