{ inputs, rootPath, system, pkgsNixOnDroid, homeModules, name, ... }:

inputs.nix-on-droid.lib.nixOnDroidConfiguration {
  inherit system;

  config = rootPath + "/hosts/${name}/nix-on-droid.nix";

  extraModules = [
    {
      nix.registry = {
        nixpkgs.flake = inputs.nixpkgs;
        nix-config.flake = inputs.self;
      };
    }
  ];

  extraSpecialArgs = {
    inherit homeModules rootPath;
  };

  pkgs = pkgsNixOnDroid;
}
