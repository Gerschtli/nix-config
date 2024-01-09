{ inputs, rootPath, system, pkgsFor, customLibFor, homeModulesFor, name, ... }:

inputs.nix-darwin.lib.darwinSystem {
  inherit system;

  specialArgs = {
    inherit inputs rootPath;
    homeModules = homeModulesFor.${system};
  };

  modules = [
    "${rootPath}/hosts/${name}/configuration.nix"

    {
      _file = ./mkDarwin.nix;

      custom.base.general.hostname = name;

      lib.custom = customLibFor.${system};

      nixpkgs = {
        hostPlatform = system;
        pkgs = pkgsFor.${system};
      };
    }
  ] ++ customLibFor.${system}.listNixFilesRecursive "${rootPath}/darwin";
}
