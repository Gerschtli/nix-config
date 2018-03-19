{ config, lib, pkgs, ... } @ args:

let
  customLib = import ./lib args;
in

{
  _module.args.dirs = {
    files = ./files;
    keys = ../keys;
    lib = ./lib;
    overlays = ./overlays;
    secrets = ./secrets;
  };

  imports = [ ../hardware-configuration.nix ]
    ++ (customLib.getRecursiveFileList ./config);
}
