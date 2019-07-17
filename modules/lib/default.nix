{ lib, ... } @ args:

let
  callPackage = lib.callPackageWith args;

  fileList = callPackage ./file-list.nix { };
in

{
  inherit (fileList) getFileList getRecursiveFileList;
}
