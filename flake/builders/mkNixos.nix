{ inputs, rootPath, system, pkgsFor, customLibFor, homeModulesFor, name, ... }:

inputs.nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit inputs rootPath;
    homeModules = homeModulesFor.${system};
  };

  modules = [
    "${rootPath}/hosts/${name}/configuration.nix"
    "${rootPath}/hosts/${name}/hardware-configuration.nix"

    {
      _file = ./mkNixos.nix;

      custom.base.general.hostname = name;

      lib.custom = customLibFor.${system};

      nixpkgs.pkgs = pkgsFor.${system};
    }
  ]
  ++ customLibFor.${system}.listNixFilesRecursive "${rootPath}/nixos";
}
