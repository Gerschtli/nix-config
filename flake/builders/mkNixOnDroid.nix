{ inputs, rootPath, system, pkgsNixOnDroid, homeModules, name, ... }:

# FIXME: pass in instance of pkgs when argument is added
inputs.nix-on-droid.lib.${system}.nix-on-droid {
  config = import (rootPath + "/hosts/${name}/nix-on-droid.nix") {
    inherit homeModules rootPath;
    pkgs = pkgsNixOnDroid;
  };
}
