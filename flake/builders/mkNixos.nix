{ inputs, rootPath, system, pkgs, customLib, homeModules, name, ... }:

inputs.nixpkgs.lib.nixosSystem {
  inherit system;

  specialArgs = {
    inherit homeModules rootPath;
  };

  modules = [
    (rootPath + "/hosts/${name}/configuration.nix")
    (rootPath + "/hosts/${name}/hardware-configuration.nix")

    inputs.agenix.nixosModules.age
    inputs.home-manager.nixosModules.home-manager

    {
      custom.base.general.hostname = name;

      lib.custom = customLib;

      nixpkgs = {
        inherit pkgs;
      };

      nix.registry = {
        nixpkgs.flake = inputs.nixpkgs;
        nix-config.flake = inputs.self;
      };

      system.configurationRevision = inputs.self.rev or "dirty";
    }
  ]
  ++ customLib.getRecursiveNixFileList (rootPath + "/nixos");
}
