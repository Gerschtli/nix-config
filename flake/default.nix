{ inputs, rootPath }:

let
  homeModulesBuilder = { inputs, rootPath, customLib, ... }:
    [
      inputs.homeage.homeManagerModules.homeage

      {
        lib.custom = customLib;
      }
    ]
    ++ customLib.getRecursiveNixFileList (rootPath + "/home");

  wrapper = builder: system: name: args:
    let
      flakeArgs = { inherit inputs rootPath system; };
      perSystem = import ./per-system.nix flakeArgs;

      homeModules = homeModulesBuilder (flakeArgs // perSystem);

      builderArgs = flakeArgs // perSystem // { inherit args homeModules name; };
    in
    inputs.nixpkgs.lib.nameValuePair name (import builder builderArgs);

  simpleWrapper = builder: system: name: wrapper builder system name { };
in

{
  mkHome = simpleWrapper ./builders/mkHome.nix;
  mkNixOnDroid = simpleWrapper ./builders/mkNixOnDroid.nix;
  mkNixos = simpleWrapper ./builders/mkNixos.nix;

  eachSystem = builderPerSystem:
    inputs.flake-utils.lib.eachSystem
      [ "aarch64-linux" "x86_64-linux" ]
      (system:
        builderPerSystem {
          inherit system;
          mkApp = wrapper ./builders/mkApp.nix system;
          mkDevShellJdk = wrapper ./builders/mkDevShellJdk.nix system;
          mkDevShellPhp = wrapper ./builders/mkDevShellPhp.nix system;
        }
      );
}
