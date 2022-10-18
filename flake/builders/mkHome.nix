{ inputs, rootPath, system, pkgsFor, homeModulesFor, name, ... }:

let
  # splits "username@hostname"
  splittedName = inputs.nixpkgs.lib.splitString "@" name;

  username = builtins.elemAt splittedName 0;
  hostname = builtins.elemAt splittedName 1;
in

inputs.home-manager.lib.homeManagerConfiguration {
  inherit username system;

  pkgs = pkgsFor.${system};
  configuration = "${rootPath}/hosts/${hostname}/home-${username}.nix";
  homeDirectory = "/home/${username}";
  stateVersion = "22.05";

  extraModules = homeModulesFor.${system} ++ [
    {
      _file = ./mkHome.nix;
      nix.registry = {
        nixpkgs.flake = inputs.nixpkgs;
        nix-config.flake = inputs.self;
      };
    }
  ];

  extraSpecialArgs = {
    inherit inputs rootPath;
  };
}
