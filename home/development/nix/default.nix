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
      [ pkgs.nix-output-monitor pkgs.nvd ]
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
          "nix build --log-format internal-json --verbose \"${nixConfigDir}#homeConfigurations.\\\"$(whoami)@$(hostname)\\\".activationPackage\" |& nom --json"
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
          "nix build --log-format internal-json --verbose \"${nixConfigDir}#nixOnDroidConfigurations.pixel7a.activationPackage\" --impure |& nom --json"
          "/nix/var/nix/profiles/nix-on-droid"
        )
      ];
    })

    (mkIf cfg.nixos.enable {
      home.packages = [
        (config.lib.custom.mkScript
          "n-rebuild"
          ./n-rebuild.sh
          [ pkgs.ccze pkgs.nix-output-monitor ]
          {
            inherit nixConfigDir;
            buildCmd = "${buildWithDiff
              "n-rebuild-build"
              "sudo nix build --log-format internal-json --verbose \"${nixConfigDir}#nixosConfigurations.$(hostname).config.system.build.toplevel\" |& nom --json"
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
