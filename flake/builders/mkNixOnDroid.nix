{ inputs, rootPath, system, pkgsNixOnDroid, homeModules, name, ... }:

inputs.nix-on-droid.lib.nixOnDroidConfiguration {
  inherit system;

  config = rootPath + "/hosts/${name}/nix-on-droid.nix";

  extraSpecialArgs = {
    inherit homeModules rootPath;
  };

  pkgs = pkgsNixOnDroid;
}
