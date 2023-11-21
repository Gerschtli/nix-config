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

      lib.custom = customLibFor.${system};

      networking = {
        computerName = name;
        hostName = name;
        localHostName = name;
      };

      nixpkgs = {
        hostPlatform = system;
        pkgs = pkgsFor.${system};
      };
    }
  ]; # ++ customLibFor.${system}.listNixFilesRecursive "${rootPath}/darwin";
}
