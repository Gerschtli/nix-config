{ lib, ... } @ args:

let
  callPackage = lib.callPackageWith args;

  fileList = callPackage ./file-list.nix { };
in

{
  inherit (fileList) getFileList getRecursiveFileList;

  containerApp = callPackage ./container-app.nix { };
  staticPage = callPackage ./static-page.nix { };
}
