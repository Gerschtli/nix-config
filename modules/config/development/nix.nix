{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.development.nix;

  devHomeManager = "/home/tobias/projects/home-manager";
  devNixpkgs = "/home/tobias/projects/nixpkgs";
  devNurGerschtli = "/home/tobias/projects/nur-packages";

  buildWithDiff = buildCommand: activeLinkPath: toString (pkgs.writeScript "build-with-diff" ''
    #!${pkgs.runtimeShell} -e

    ${buildCommand}

    echo

    # see https://github.com/madjar/nox/issues/63#issuecomment-303280129
    nox-update --quiet ${activeLinkPath} result | \
        grep -v '\.drv : $' | \
        sed 's|^ */nix/store/[a-z0-9]*-||' | \
        sort -u

    rm result
  '');
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
        hm-build  = buildWithDiff "home-manager build" "/nix/var/nix/profiles/per-user/tobias/home-manager";
        hm-switch = "home-manager switch -b hm-bak";
      };
    })

    (mkIf cfg.nix-on-droid.enable {
      custom.programs.shell.shellAliases = {
        nod-build  = buildWithDiff "nix-on-droid build" "/nix/var/nix/profiles/nix-on-droid";
        nod-switch = "nix-on-droid switch";
      };
    })

    (mkIf cfg.nixos.enable {
      custom.programs.shell.shellAliases = {
        n-rebuild-build   = buildWithDiff "nixos-rebuild build" "/run/current-system";
        n-rebuild-dev-all = "nixos-rebuild test --fast -I home-manager=${devHomeManager} -I nixpkgs=${devNixpkgs}";
        n-rebuild-dev-hm  = "nixos-rebuild test --fast -I home-manager=${devHomeManager}";
        n-rebuild-dev-ng  = "nixos-rebuild test --fast -I nur-gerschtli=${devNurGerschtli}";
        n-rebuild-dev-np  = "nixos-rebuild test --fast -I nixpkgs=${devNixpkgs}";
        n-rebuild-switch  = "nixos-rebuild switch";
        n-rebuild-test    = "nixos-rebuild test";
      };
    })

  ];

}
