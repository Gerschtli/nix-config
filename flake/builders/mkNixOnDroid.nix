{ inputs, rootPath, system, pkgsNixOnDroidFor, homeModulesFor, name, ... }:

inputs.nix-on-droid.lib.nixOnDroidConfiguration {
  inherit system;

  config = "${rootPath}/hosts/${name}/nix-on-droid.nix";

  extraModules = [
    {
      _file = ./mkNixOnDroid.nix;
      nix.registry = {
        nixpkgs.flake = inputs.nixpkgs;
        nix-config.flake = inputs.self;
      };
    }
  ];

  extraSpecialArgs = {
    inherit inputs rootPath;
    homeModules = homeModulesFor.${system};
  };

  pkgs = pkgsNixOnDroidFor.${system};
}
