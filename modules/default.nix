{ config, lib, pkgs, ... } @ args:

let
  customLib = import ./lib args;

  nurGerschtliImports = import <nur-gerschtli/hm-modules/imports.nix>;
in

{
  imports = customLib.getRecursiveFileList ./config
    ++ nurGerschtliImports;
}
