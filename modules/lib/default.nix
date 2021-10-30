{ lib, ... } @ args:

let
  callPackage = lib.callPackageWith args;

  fileList = callPackage ./file-list.nix { };
  script = callPackage ./script { };
  wrapProgram = callPackage ./wrap-program.nix { };
in

{
  inherit (fileList) getFileList getRecursiveNixFileList;
  inherit (script) buildScript buildZshCompletion;
  inherit (wrapProgram) wrapProgram;

  path = {
    modules = ../.;
    config = ../config;
    files = ../files;
    overlays = ../overlays;
    secrets = toString ../secrets;
  };
}
