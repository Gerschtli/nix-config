{ pkgs }:

let
  callPackage = pkgs.lib.callPackageWith {
    inherit pkgs;
    inherit (pkgs) lib;
  };

  commonConfig = callPackage ./common-config.nix { };
  fileList = callPackage ./file-list.nix { };
  script = callPackage ./script { };
  wrapProgram = callPackage ./wrap-program.nix { };
in

{
  inherit commonConfig;
  inherit (fileList) listNixFilesRecursive;
  inherit (script) mkScript mkScriptPlain mkScriptPlainNixShell mkZshCompletion;
  inherit (wrapProgram) wrapProgram;
}
