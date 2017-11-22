{ config, lib, pkgs, ... } @ args:

let
  customLib = import ./lib args;
in

{
  imports = [ ../hardware-configuration.nix ]
    ++ (customLib.getRecursiveFileList ./config);
}
