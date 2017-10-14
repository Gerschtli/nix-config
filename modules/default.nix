{ config, lib, pkgs, ... }:

let
  getRecursiveFileList = import ./lib/get-recursive-file-list.nix { inherit lib; };
in

{
  imports = [ ../hardware-configuration.nix ]
    ++ (getRecursiveFileList ./config);
}
