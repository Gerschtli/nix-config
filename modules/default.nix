hostName:

{ config, lib, pkgs, ... } @ args:

let
  customLib = import ./lib args;
in

{
  imports = [ (customLib.path.hardwareConfiguration + "/${hostName}.nix") ]
    ++ customLib.getRecursiveFileList customLib.path.config;

  config = {
    custom.base.general = { inherit hostName; };

    lib.custom = customLib;
  };
}
