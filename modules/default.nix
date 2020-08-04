hostName:

{ config, lib, pkgs, ... } @ args:

let
  customLib = import ./lib args;
in

{
  imports = [ (./hardware-configuration + "/${hostName}.nix") ]
    ++ customLib.getRecursiveFileList ./config;

  config = {
    custom.base.general = { inherit hostName; };
  };
}
