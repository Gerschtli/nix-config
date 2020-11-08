{ lib, ... } @ args:

let
  callPackage = lib.callPackageWith args;

  fileList = callPackage ./file-list.nix { };
  wrapProgram = callPackage ./wrap-program.nix { };
in

{
  inherit (fileList)
    getDirectoryList
    getRecursiveDirectoryList1
    getFileList
    getRecursiveFileList;

  inherit (wrapProgram) wrapProgram;
}
