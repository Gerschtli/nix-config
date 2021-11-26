{ config, lib, pkgs, ... } @ args:

let
  customLib = import ./lib args;
in

{
  imports = customLib.getRecursiveNixFileList customLib.path.config;

  config.lib.custom = customLib;
}
