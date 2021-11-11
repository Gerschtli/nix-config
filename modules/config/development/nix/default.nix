{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.development.nix;

  buildWithDiff = name: command: activeLinkPath:
    config.lib.custom.mkScript
      name
      ./build-with-diff.sh
      [ pkgs.gnugrep pkgs.gnused pkgs.nox ]
      {
        inherit activeLinkPath command;
        _doNotClearPath = true;
      };

  forkDir = "/home/tobias/projects";
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
      home.packages = [
        (config.lib.custom.mkScript
          "n-rebuild"
          ./n-rebuild.sh
          [ pkgs.ccze ]
          {
            inherit forkDir;
            buildCmd = "${buildWithDiff "n-rebuild-build" "nixos-rebuild" "/run/current-system"}/bin/n-rebuild-build";
            _doNotClearPath = true;
          }
        )

        (config.lib.custom.mkZshCompletion
          "n-rebuild"
          ./n-rebuild-completion.zsh
          { inherit forkDir; }
        )
      ];
    })

  ];

}
