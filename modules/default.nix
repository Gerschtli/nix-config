{ config, lib, pkgs, ... } @ args:

let
  customLib = import ./lib args;
in

{
  imports = customLib.getRecursiveFileList customLib.path.config;

  config.lib.custom = customLib;
}
