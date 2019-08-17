{ config, lib, pkgs, ... } @ args:

with lib;

let
  cfg = config.custom.development.nixos;

  devHomeManager = "/home/tobias/projects/home-manager";
  devNixpkgs = "/home/tobias/projects/nixpkgs";

  rebuildBuild = pkgs.writeScript "nixos-rebuild-build" ''
    #!${pkgs.runtimeShell} -e

    nixos-rebuild build

    echo

    # see https://github.com/madjar/nox/issues/63#issuecomment-303280129
    nox-update --quiet /run/current-system result | \
        grep -v '\.drv : $' | \
        sed 's|^ */nix/store/[a-z0-9]*-||' | \
        sort -u

    rm result
  '';
in

{

  ###### interface

  options = {

    custom.development.nixos.enable = mkEnableOption "nixos aliases";

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.shell.shellAliases = {
      n-rebuild-build   = toString rebuildBuild;
      n-rebuild-dev     = "nixos-rebuild test --fast";
      n-rebuild-dev-all = "nixos-rebuild test --fast -I home-manager=${devHomeManager} -I nixpkgs=${devNixpkgs}";
      n-rebuild-dev-hm  = "nixos-rebuild test --fast -I home-manager=${devHomeManager}";
      n-rebuild-dev-np  = "nixos-rebuild test --fast -I nixpkgs=${devNixpkgs}";
      n-rebuild-switch  = "nixos-rebuild switch";
      n-rebuild-test    = "nixos-rebuild test";
    };

  };

}
