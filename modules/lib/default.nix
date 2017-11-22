{ lib, ... } @ args:

let
  callPackage = lib.callPackageWith args;
in

{
  containerApp = callPackage ./container-app.nix { };
  fetchBitbucket = callPackage ./fetch-bitbucket.nix { };
  getRecursiveFileList = callPackage ./get-recursive-file-list.nix { };
}
