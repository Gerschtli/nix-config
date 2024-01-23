{ config, lib, pkgs, rootPath, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    ;

  cfg = config.custom.development.nix;

  nixConfigDir = "${config.home.homeDirectory}/.nix-config";

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
        nrepl = "nix repl --file ${replFile}";
      };
    }

    (mkIf cfg.home-manager.enable {
      custom.programs.shell.shellAliases = {
        hm-switch = "home-manager switch -b hm-bak --flake '${nixConfigDir}'";
      };

      home.packages = [
        (buildWithDiff
          "hm-build"
          "home-manager build --flake '${nixConfigDir}'"
          "${config.home.homeDirectory}/.local/state/nix/profiles/home-manager"
        )
      ];
    })

    (mkIf cfg.nix-on-droid.enable {
      custom.programs.shell.shellAliases = {
        nod-switch = "nix-on-droid switch --flake '${nixConfigDir}#pixel7a'";
      };

      home.packages = [
        (buildWithDiff
          "nod-build"
          "nix-on-droid build --flake '${nixConfigDir}#pixel7a'"
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
            inherit nixConfigDir;
            buildCmd = "${buildWithDiff
              "n-rebuild-build"
              "sudo nixos-rebuild build --flake '${nixConfigDir}'"
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
