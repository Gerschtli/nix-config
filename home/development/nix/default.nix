{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.development.nix;

  buildWithDiff = name: command: activeLinkPath:
    config.lib.custom.mkScript
      name
      ./build-with-diff.sh
      [ pkgs.gnugrep pkgs.gnused ]
      {
        inherit (config.home) homeDirectory;
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
        hm-switch = "home-manager switch -b hm-bak --flake '${config.home.homeDirectory}/.nix-config'";
      };

      home.packages = [
        (buildWithDiff
          "hm-build"
          "home-manager build --flake '${config.home.homeDirectory}/.nix-config'"
          "/nix/var/nix/profiles/per-user/${config.home.username}/home-manager"
        )
      ];
    })

    (mkIf cfg.nix-on-droid.enable {
      # FIXME: use nix-on-droid command again once flake support is available
      custom.programs.shell.shellAliases = {
        nod-switch = "nix build .#nixOnDroidConfigurations.oneplus5.activationPackage --impure && ./result/activate";
      };

      home.packages = [
        (buildWithDiff
          "nod-build"
          "nix build .#nixOnDroidConfigurations.oneplus5.activationPackage --impure"
          "/nix/var/nix/profiles/nix-on-droid"
        )
      ];
    })

    (mkIf cfg.nixos.enable {
      home.packages = [
        (config.lib.custom.mkScript
          "n-rebuild"
          ./n-rebuild.sh
          [ pkgs.ccze ]
          {
            buildCmd = "${buildWithDiff
              "n-rebuild-build"
              "nixos-rebuild build --flake /root/.nix-config"
              "/run/current-system"
            }/bin/n-rebuild-build";
            _doNotClearPath = true;
          }
        )

        (config.lib.custom.mkZshCompletion
          "n-rebuild"
          ./n-rebuild-completion.zsh
          { }
        )
      ];
    })

  ];

}
