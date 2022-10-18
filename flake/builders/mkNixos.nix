{ inputs, rootPath, system, pkgsFor, customLibFor, homeModulesFor, name, ... }:

inputs.nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit rootPath;
    homeModules = homeModulesFor.${system};
  };

  modules = [
    (rootPath + "/hosts/${name}/configuration.nix")
    (rootPath + "/hosts/${name}/hardware-configuration.nix")

    inputs.agenix.nixosModules.age
    inputs.home-manager.nixosModules.home-manager

    {
      _file = ./mkNixos.nix;

      custom.base.general.hostname = name;

      lib.custom = customLibFor.${system};

      nixpkgs.pkgs = pkgsFor.${system};

      nix.registry = {
        nixpkgs.flake = inputs.nixpkgs;
        nix-config.flake = inputs.self;
      };

      system.configurationRevision = inputs.self.rev or "dirty";
    }
  ]
  ++ customLibFor.${system}.getRecursiveNixFileList (rootPath + "/nixos");
}
