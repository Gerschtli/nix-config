{ config, lib, pkgs, rootPath, ... }:

with lib;

let
  cfg = config.custom.development.nix;

  buildWithDiff = name: command: activeLinkPath:
    config.lib.custom.mkScript
      name
      ./build-with-diff.sh
      [ pkgs.nvd ]
      {
        inherit (config.home) homeDirectory;
        inherit activeLinkPath command;
        _doNotClearPath = true;
      };

  replFile = pkgs.runCommand
    "repl.nix"
    { }
    ''
      cp ${./repl.nix.template} ${placeholder "out"}
    '';
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

    {
      custom.programs.shell.shellAliases = {
        nrepl = "nix repl ${replFile}";
      };
    }

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
      custom.programs.shell.shellAliases = {
        nod-switch = "nix-on-droid switch --flake '${config.home.homeDirectory}/.nix-config#oneplus5'";
      };

      home.packages = [
        (buildWithDiff
          "nod-build"
          "nix-on-droid build --flake '${config.home.homeDirectory}/.nix-config#oneplus5'"
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
              "/nix/var/nix/profiles/system"
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
