{ lib, pkgs } @ args:

let
  callPackage = lib.callPackageWith args;

  fileList = callPackage ./file-list.nix { };
  script = callPackage ./script { };
  wrapProgram = callPackage ./wrap-program.nix { };
in

{
  inherit (fileList) getFileList getRecursiveNixFileList;
  inherit (script) mkScript mkScriptPlain mkScriptPlainNixShell mkZshCompletion;
  inherit (wrapProgram) wrapProgram;
}
