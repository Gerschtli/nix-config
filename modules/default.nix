{ config, lib, pkgs, ... } @ args:

let
  customLib = import ./lib args;
in

{
  imports = customLib.getRecursiveFileList ./config;
}
