{ lib, pkgs, ... } @ args:

let
  callPackage = lib.callPackageWith args;

  homeManagerLib = callPackage ../../home-manager-configurations/modules/lib { };
in

{
  inherit (homeManagerLib) getFileList getRecursiveNixFileList mkScript mkScriptPlainNixShell;

  path = {
    modules = ../.;
    config = ../config;
    files = ../files;
    hardwareConfiguration = ../hardware-configuration;
    homeFiles = ../../home-manager-configurations/home-files;
    overlays = ../../home-manager-configurations/modules/overlays;
    secrets = toString ../secrets;
  };
}
