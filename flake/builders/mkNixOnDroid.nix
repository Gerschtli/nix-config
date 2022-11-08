{ inputs, rootPath, system, pkgsNixOnDroidFor, homeModulesFor, name, ... }:

inputs.nix-on-droid.lib.nixOnDroidConfiguration {
  pkgs = pkgsNixOnDroidFor.${system};
  modules = [ "${rootPath}/hosts/${name}/nix-on-droid.nix" ];

  extraSpecialArgs = {
    inherit inputs rootPath;
    homeModules = homeModulesFor.${system};
  };
}
