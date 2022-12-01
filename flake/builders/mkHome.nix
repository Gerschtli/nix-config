{ inputs, rootPath, system, pkgsFor, homeModulesFor, name, ... }:

let
  # splits "username@hostname"
  splittedName = inputs.nixpkgs.lib.splitString "@" name;

  username = builtins.elemAt splittedName 0;
  hostname = builtins.elemAt splittedName 1;
in

inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = pkgsFor.${system};
  extraSpecialArgs = { inherit inputs rootPath; };

  modules = [ "${rootPath}/hosts/${hostname}/home-${username}.nix" ]
    ++ homeModulesFor.${system};
}
