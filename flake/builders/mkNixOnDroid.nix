{ inputs, rootPath, system, pkgsNixOnDroidFor, homeModulesFor, name, ... }:

inputs.nix-on-droid.lib.nixOnDroidConfiguration {
  inherit system;

  pkgs = pkgsNixOnDroidFor.${system};
  config = "${rootPath}/hosts/${name}/nix-on-droid.nix";

  extraSpecialArgs = {
    inherit inputs rootPath;
    homeModules = homeModulesFor.${system};
  };
}
